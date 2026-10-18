package com.stockrobot.luafieldviewer

import android.content.ClipData
import android.content.ClipboardManager
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.view.View
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import androidx.core.widget.doAfterTextChanged
import androidx.recyclerview.widget.LinearLayoutManager
import com.stockrobot.luafieldviewer.data.FileRepository
import com.stockrobot.luafieldviewer.data.TextDecoder
import com.stockrobot.luafieldviewer.databinding.ActivityFieldDetailBinding
import com.stockrobot.luafieldviewer.lua.LuaParseException
import com.stockrobot.luafieldviewer.lua.LuaParser
import com.stockrobot.luafieldviewer.lua.LuaScalar
import com.stockrobot.luafieldviewer.lua.ParseResult
import com.stockrobot.luafieldviewer.net.RemoteServerClient
import com.stockrobot.luafieldviewer.settings.AppSettings
import com.stockrobot.luafieldviewer.tree.TreeAdapter
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale
import java.util.concurrent.Executors

/**
 * Второй экран: просмотр значений полей выбранного файла.
 *
 * Режимы (переключатель сверху):
 *  - «Дерево» — раскрываемая таблица «ключ → значение» с поиском;
 *  - «Текст» — исходный текст файла (для больших файлов — первые символы).
 *
 * Разбор файла выполняется в фоновом потоке; при ошибке разбора предлагается
 * посмотреть файл как текст.
 *
 * Для файлов с сервера содержимое автоматически перечитывается с заданным
 * в настройках периодом: файл запрашивается с заголовком If-Modified-Since,
 * и при ответе «304 Not Modified» экран не перерисовывается.
 */
class FieldDetailActivity : AppCompatActivity() {

    private lateinit var binding: ActivityFieldDetailBinding
    private val repository by lazy { FileRepository(this) }
    private val settings by lazy { AppSettings(this) }
    private val executor = Executors.newSingleThreadExecutor()
    private val handler = Handler(Looper.getMainLooper())
    private val timeFormat = SimpleDateFormat("HH:mm:ss", Locale.getDefault())

    private lateinit var adapter: TreeAdapter
    private var parseResult: ParseResult? = null
    private var rawText: String? = null

    private var kind: String? = null
    private var ref: String? = null
    private var kindServer = false
    private var lastModified: Long = 0L
    private var refreshScheduled = false

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityFieldDetailBinding.inflate(layoutInflater)
        setContentView(binding.root)

        kind = intent.getStringExtra(EXTRA_KIND)
        ref = intent.getStringExtra(EXTRA_REF)
        kindServer = kind == KIND_SERVER

        val fileName = intent.getStringExtra(EXTRA_NAME) ?: getString(R.string.app_name)
        setSupportActionBar(binding.toolbar)
        supportActionBar?.setDisplayHomeAsUpEnabled(true)
        supportActionBar?.title = fileName

        adapter = TreeAdapter(onScalarClick = { copyValue(it) })
        adapter.onRowsChanged = { updateNoResults() }
        binding.treeList.layoutManager = LinearLayoutManager(this)
        binding.treeList.adapter = adapter

        binding.searchEdit.doAfterTextChanged { editable ->
            adapter.setQuery(editable?.toString() ?: "")
            updateNoResults()
        }

        binding.modeGroup.addOnButtonCheckedListener { _, checkedId, isChecked ->
            if (!isChecked) return@addOnButtonCheckedListener
            when (checkedId) {
                R.id.modeTree -> showTree()
                R.id.modeText -> showText()
            }
        }
        binding.showTextButton.setOnClickListener { binding.modeGroup.check(R.id.modeText) }

        load()
    }

    override fun onDestroy() {
        handler.removeCallbacksAndMessages(null)
        executor.shutdownNow()
        super.onDestroy()
    }

    override fun onSupportNavigateUp(): Boolean {
        finish()
        return true
    }

    // ---------------- загрузка ----------------
    private fun load() {
        val ref = this.ref
        if (ref.isNullOrBlank()) {
            finish()
            return
        }
        binding.progress.visibility = View.VISIBLE

        executor.execute {
            val outcome: Outcome = if (kindServer) {
                readFromServer(ref, previousLastModified = 0L)
            } else {
                readLocal(ref)
            }
            handler.post { onLoaded(outcome, isRefresh = false) }
        }
    }

    private fun readLocal(ref: String): Outcome = try {
        val bytes = when (kind) {
            KIND_ASSET -> repository.readAsset(ref)
            else -> repository.readDocument(Uri.parse(ref))
        }
        val text = TextDecoder.decode(bytes)
        parse(text)
    } catch (t: Throwable) {
        Outcome.ReadFailed(t.message ?: t.javaClass.simpleName)
    }

    /**
     * Чтение файла с сервера. При [previousLastModified] > 0 файл не менялся —
     * сервер отвечает 304, и возвращается [Outcome.NotModified].
     */
    private fun readFromServer(ref: String, previousLastModified: Long): Outcome {
        if (!settings.isConfigured) {
            return Outcome.ReadFailed(getString(R.string.server_off_short))
        }
        val client = RemoteServerClient(settings.baseUrl())
        return try {
            val content = client.readFile(ref, previousLastModified)
                ?: return Outcome.NotModified
            lastModified = content.lastModified
            parse(TextDecoder.decode(content.bytes))
        } catch (t: Throwable) {
            Outcome.ReadFailed(t.message ?: t.javaClass.simpleName)
        }
    }

    private fun parse(text: String): Outcome = try {
        Outcome.Parsed(text, LuaParser.parse(text))
    } catch (e: LuaParseException) {
        Outcome.ParseFailed(text, e)
    }

    private sealed class Outcome {
        class Parsed(val text: String, val result: ParseResult) : Outcome()
        class ParseFailed(val text: String, val error: LuaParseException) : Outcome()
        class ReadFailed(val reason: String) : Outcome()
        object NotModified : Outcome()
    }

    private fun onLoaded(outcome: Outcome, isRefresh: Boolean) {
        binding.progress.visibility = View.GONE
        when (outcome) {
            is Outcome.NotModified -> {
                // Файл не изменился — только отметим время проверки.
                markServerChecked()
            }
            is Outcome.Parsed -> {
                rawText = outcome.text
                parseResult = outcome.result
                val result = outcome.result
                binding.statsText.text = getString(
                    R.string.stats_format,
                    result.fieldCount, result.tableCount, result.maxDepth
                )
                if (isRefresh) {
                    // Сохраняем раскрытые пользователем узлы и текущий поиск.
                    adapter.updateRoot(result.root)
                } else {
                    adapter.setRoot(result.root)
                    binding.modeGroup.check(R.id.modeTree)
                }
                if (binding.rawScroll.visibility == View.VISIBLE) {
                    binding.rawText.text = rawForDisplay(outcome.text)
                }
                markServerChecked()
            }
            is Outcome.ParseFailed -> {
                rawText = outcome.text
                binding.errorText.text = buildErrorText(outcome.error)
                binding.showTextButton.visibility = View.VISIBLE
                if (!isRefresh) binding.modeGroup.check(R.id.modeTree)
            }
            is Outcome.ReadFailed -> {
                if (isRefresh && parseResult != null) {
                    // Уже есть данные — не затираем экран, только отмечаем ошибку.
                    supportActionBar?.subtitle = getString(R.string.server_error, outcome.reason)
                } else {
                    parseResult = null
                    rawText = null
                    binding.errorText.text =
                        "${getString(R.string.read_error)}\n${outcome.reason}"
                    binding.showTextButton.visibility = View.GONE
                    binding.modeGroup.check(R.id.modeTree)
                }
            }
        }
        updateNoResults()
    }

    private fun markServerChecked() {
        if (kindServer) {
            supportActionBar?.subtitle = getString(R.string.server_updated_time, timeFormat.format(Date()))
        }
    }

    // ---------------- автообновление файла с сервера ----------------
    override fun onResume() {
        super.onResume()
        if (kindServer) scheduleRefresh()
    }

    override fun onPause() {
        handler.removeCallbacksAndMessages(null)
        refreshScheduled = false
        super.onPause()
    }

    private fun scheduleRefresh() {
        if (refreshScheduled) return
        val intervalSec = settings.refreshIntervalSec.coerceAtLeast(1)
        refreshScheduled = true
        handler.postDelayed(
            {
                refreshScheduled = false
                refreshServerFile()
                scheduleRefresh()
            },
            intervalSec * 1000L
        )
    }

    private fun refreshServerFile() {
        val ref = this.ref ?: return
        executor.execute {
            val outcome = readFromServer(ref, previousLastModified = lastModified)
            handler.post { onLoaded(outcome, isRefresh = true) }
        }
    }

    private fun buildErrorText(error: LuaParseException): String = buildString {
        append(getString(R.string.parse_error_title))
        append('\n')
        append(getString(R.string.error_position, error.line, error.column))
        append('\n')
        append(error.reason)
        val snippet = error.snippet.trim()
        if (snippet.isNotEmpty()) {
            append("\n« ")
            append(snippet)
            append(" »")
        }
    }

    // ---------------- переключение режимов ----------------
    private fun showTree() {
        val ok = parseResult != null
        binding.searchBox.visibility = if (ok) View.VISIBLE else View.GONE
        binding.statsText.visibility = if (ok) View.VISIBLE else View.GONE
        binding.treeList.visibility = if (ok) View.VISIBLE else View.GONE
        binding.rawScroll.visibility = View.GONE
        binding.errorView.visibility = if (ok) View.GONE else View.VISIBLE
        if (ok) updateNoResults() else binding.noResults.visibility = View.GONE
    }

    private fun showText() {
        binding.searchBox.visibility = View.GONE
        binding.statsText.visibility = View.GONE
        binding.treeList.visibility = View.GONE
        binding.errorView.visibility = View.GONE
        binding.noResults.visibility = View.GONE

        val text = rawText
        binding.rawScroll.visibility = if (text != null) View.VISIBLE else View.GONE
        binding.rawText.text = text?.let { rawForDisplay(it) }
    }

    private fun rawForDisplay(text: String): String =
        if (text.length <= MAX_RAW_CHARS) {
            text
        } else {
            getString(R.string.text_limit_note, MAX_RAW_CHARS, text.length) +
                "\n\n" + text.substring(0, MAX_RAW_CHARS)
        }

    private fun updateNoResults() {
        val visible = binding.modeGroup.checkedButtonId == R.id.modeTree &&
            parseResult != null &&
            adapter.isSearching &&
            adapter.itemCount == 0
        binding.noResults.visibility = if (visible) View.VISIBLE else View.GONE
    }

    // ---------------- копирование значения ----------------
    private fun copyValue(scalar: LuaScalar) {
        val clipboard = getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
        clipboard.setPrimaryClip(ClipData.newPlainText(scalar.key, scalar.valueText()))
        Toast.makeText(this, R.string.copied, Toast.LENGTH_SHORT).show()
    }

    companion object {
        private const val EXTRA_KIND = "extra_kind"
        private const val EXTRA_REF = "extra_ref"
        private const val EXTRA_NAME = "extra_name"
        private const val KIND_ASSET = "asset"
        private const val KIND_SERVER = "server"
        private const val MAX_RAW_CHARS = 200_000

        /** Открыть встроенный образец из assets. */
        fun startAsset(context: Context, assetName: String, displayName: String) {
            context.startActivity(
                buildIntent(context, KIND_ASSET, assetName, displayName)
            )
        }

        /** Открыть документ, выбранный через системный выборщик. */
        fun startDocument(context: Context, uri: String, displayName: String) {
            context.startActivity(
                buildIntent(context, "document", uri, displayName)
            )
        }

        /** Открыть файл из каталога на сервере (с автообновлением). */
        fun startServer(context: Context, fileName: String, displayName: String) {
            context.startActivity(
                buildIntent(context, KIND_SERVER, fileName, displayName)
            )
        }

        private fun buildIntent(
            context: Context,
            kind: String,
            ref: String,
            name: String
        ): Intent = Intent(context, FieldDetailActivity::class.java)
            .putExtra(EXTRA_KIND, kind)
            .putExtra(EXTRA_REF, ref)
            .putExtra(EXTRA_NAME, name)
    }
}
