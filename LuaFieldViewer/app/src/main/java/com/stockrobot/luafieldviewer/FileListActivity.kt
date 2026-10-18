package com.stockrobot.luafieldviewer

import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.view.LayoutInflater
import android.view.Menu
import android.view.MenuItem
import android.view.View
import android.view.ViewGroup
import androidx.activity.result.contract.ActivityResultContracts
import androidx.appcompat.app.AppCompatActivity
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.google.android.material.dialog.MaterialAlertDialogBuilder
import com.stockrobot.luafieldviewer.data.FileRepository
import com.stockrobot.luafieldviewer.databinding.ActivityFileListBinding
import com.stockrobot.luafieldviewer.databinding.ItemFileBinding
import com.stockrobot.luafieldviewer.net.RemoteFile
import com.stockrobot.luafieldviewer.net.RemoteServerClient
import com.stockrobot.luafieldviewer.settings.AppSettings
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale
import java.util.concurrent.Executors

/**
 * Первый экран: список файлов для просмотра.
 *  - файлы каталога на сервере (адрес и каталог — в настройках), список
 *    автоматически перечитывается с заданным периодом;
 *  - встроенные образцы (tool.txt, trends.txt, toolset.txt, setting.txt);
 *  - документы, выбранные через системный выборщик (запоминаются).
 * Долгое нажатие на документ — убрать его из списка.
 */
class FileListActivity : AppCompatActivity() {

    private enum class Kind { SERVER, SAMPLE, DOCUMENT }

    private data class FileItem(
        val kind: Kind,
        val name: String,
        val subtitle: String,
        val ref: String
    )

    private lateinit var binding: ActivityFileListBinding
    private val repository by lazy { FileRepository(this) }
    private val settings by lazy { AppSettings(this) }
    private lateinit var adapter: FileAdapter

    private val executor = Executors.newSingleThreadExecutor()
    private val handler = Handler(Looper.getMainLooper())
    private val timeFormat = SimpleDateFormat("HH:mm:ss", Locale.getDefault())

    private var serverFiles: List<RemoteFile> = emptyList()
    private var serverError: String? = null
    private var serverCheckedAt: Date? = null
    private var refreshScheduled = false
    private var lastConfigSignature: String? = null

    /** Подпись настроек: чтобы не сбрасывать список без реальных изменений. */
    private fun configSignature(): String =
        "${settings.host}|${settings.port}|${settings.path}|${settings.fileMask}"

    private val openDocumentLauncher =
        registerForActivityResult(ActivityResultContracts.StartActivityForResult()) { result ->
            if (result.resultCode != Activity.RESULT_OK) return@registerForActivityResult

            val picked = ArrayList<Uri>()
            val clip = result.data?.clipData
            if (clip != null) {
                for (index in 0 until clip.itemCount) {
                    clip.getItemAt(index).uri?.let { picked.add(it) }
                }
            }
            if (picked.isEmpty()) {
                result.data?.data?.let { picked.add(it) }
            }
            if (picked.isEmpty()) return@registerForActivityResult

            // Сохраняем право на чтение, чтобы файл открывался и после перезапуска.
            for (uri in picked) {
                try {
                    contentResolver.takePersistableUriPermission(
                        uri, Intent.FLAG_GRANT_READ_URI_PERMISSION
                    )
                } catch (e: SecurityException) {
                    // Провайдер не поддерживает длительное право — читаем в текущей сессии.
                }
            }
            repository.addDocuments(picked)
            reload()

            if (picked.size == 1) {
                val uriString = picked[0].toString()
                adapter.currentItems()
                    .firstOrNull { it.kind == Kind.DOCUMENT && it.ref == uriString }
                    ?.let { openItem(it) }
            }
        }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityFileListBinding.inflate(layoutInflater)
        setContentView(binding.root)
        setSupportActionBar(binding.toolbar)

        adapter = FileAdapter(
            onClick = { openItem(it) },
            onLongClick = { onItemLongClick(it) }
        )
        binding.fileList.layoutManager = LinearLayoutManager(this)
        binding.fileList.adapter = adapter
        binding.fab.setOnClickListener { openPicker() }

        reload()
    }

    override fun onCreateOptionsMenu(menu: Menu): Boolean {
        menuInflater.inflate(R.menu.menu_file_list, menu)
        return true
    }

    override fun onOptionsItemSelected(item: MenuItem): Boolean {
        if (item.itemId == R.id.actionSettings) {
            startActivity(Intent(this, SettingsActivity::class.java))
            return true
        }
        return super.onOptionsItemSelected(item)
    }

    override fun onResume() {
        super.onResume()
        // Настройки могли измениться — при смене адреса перечитываем каталог заново.
        val signature = configSignature()
        val changed = signature != lastConfigSignature
        lastConfigSignature = signature
        refreshServer(clearHistory = changed)
        scheduleRefresh()
    }

    override fun onPause() {
        handler.removeCallbacksAndMessages(null)
        refreshScheduled = false
        super.onPause()
    }

    override fun onDestroy() {
        executor.shutdownNow()
        super.onDestroy()
    }

    // ---------------- сервер ----------------

    /** Планирует следующее автообновление каталога сервера. */
    private fun scheduleRefresh() {
        if (refreshScheduled) return
        val intervalSec = settings.refreshIntervalSec.coerceAtLeast(1)
        refreshScheduled = true
        handler.postDelayed(
            {
                refreshScheduled = false
                refreshServer(clearHistory = false)
                scheduleRefresh()
            },
            intervalSec * 1000L
        )
    }

    /**
     * Перечитывает список файлов каталога в фоне.
     * @param clearHistory true — сбросить прошлый список (смена настроек).
     */
    private fun refreshServer(clearHistory: Boolean) {
        if (!settings.isConfigured) {
            serverFiles = emptyList()
            serverError = null
            serverCheckedAt = null
            reload()
            return
        }

        if (clearHistory) {
            serverFiles = emptyList()
            serverError = null
            serverCheckedAt = null
            binding.serverStatus.visibility = View.VISIBLE
            binding.serverStatus.text = getString(R.string.server_loading)
        }

        val client = RemoteServerClient(settings.baseUrl())
        executor.execute {
            val result = runCatching {
                client.listFiles().filter { settings.matchesMask(it.name) }
            }
            handler.post {
                result.fold(
                    onSuccess = { files ->
                        serverFiles = files
                        serverError = null
                        serverCheckedAt = Date()
                    },
                    onFailure = { error ->
                        serverError = error.message ?: error.javaClass.simpleName
                    }
                )
                reload()
            }
        }
    }

    private fun updateServerStatus() {
        if (!settings.isConfigured) {
            binding.serverStatus.visibility = View.GONE
            return
        }
        binding.serverStatus.visibility = View.VISIBLE
        val error = serverError
        val checkedAt = serverCheckedAt
        binding.serverStatus.text = when {
            error != null -> getString(R.string.server_error, error)
            checkedAt != null ->
                getString(R.string.server_updated, timeFormat.format(checkedAt), serverFiles.size)
            else -> getString(R.string.server_loading)
        }
    }

    // ---------------- список ----------------

    private fun reload() {
        val items = ArrayList<FileItem>()

        for (file in serverFiles) {
            items += FileItem(
                kind = Kind.SERVER,
                name = file.name,
                subtitle = getString(R.string.server_label),
                ref = file.name
            )
        }

        for (sample in repository.sampleFiles()) {
            items += FileItem(
                kind = Kind.SAMPLE,
                name = sample.name,
                subtitle = getString(R.string.sample_label),
                ref = sample.name
            )
        }

        for (doc in repository.documentFiles()) {
            val size = doc.sizeBytes
            val subtitle = if (size != null && size > 0) {
                "${getString(R.string.document_label)} · ${formatSize(size)}"
            } else {
                getString(R.string.document_label)
            }
            items += FileItem(
                kind = Kind.DOCUMENT,
                name = doc.name,
                subtitle = subtitle,
                ref = doc.uri.toString()
            )
        }

        adapter.submit(items)
        updateServerStatus()
        binding.emptyText.visibility = if (items.isEmpty()) View.VISIBLE else View.GONE
    }

    private fun formatSize(bytes: Long): String = when {
        bytes >= 1024L * 1024L -> getString(R.string.size_mb, bytes / (1024.0 * 1024.0))
        else -> getString(R.string.size_kb, ((bytes + 1023L) / 1024L).toInt())
    }

    private fun openPicker() {
        val intent = Intent(Intent.ACTION_OPEN_DOCUMENT).apply {
            addCategory(Intent.CATEGORY_OPENABLE)
            type = "*/*"
            putExtra(
                Intent.EXTRA_MIME_TYPES,
                arrayOf("text/plain", "text/*", "application/octet-stream")
            )
            putExtra(Intent.EXTRA_ALLOW_MULTIPLE, true)
        }
        openDocumentLauncher.launch(intent)
    }

    private fun openItem(item: FileItem) {
        when (item.kind) {
            Kind.SERVER -> FieldDetailActivity.startServer(this, item.ref, item.name)
            Kind.SAMPLE -> FieldDetailActivity.startAsset(this, item.ref, item.name)
            Kind.DOCUMENT -> FieldDetailActivity.startDocument(this, item.ref, item.name)
        }
    }

    private fun onItemLongClick(item: FileItem) {
        if (item.kind != Kind.DOCUMENT) return
        MaterialAlertDialogBuilder(this)
            .setTitle(R.string.remove_doc_title)
            .setMessage(R.string.remove_doc_message)
            .setPositiveButton(R.string.remove_action) { _, _ ->
                repository.removeDocument(Uri.parse(item.ref))
                reload()
            }
            .setNegativeButton(R.string.cancel, null)
            .show()
    }

    private class FileAdapter(
        private val onClick: (FileItem) -> Unit,
        private val onLongClick: (FileItem) -> Unit
    ) : RecyclerView.Adapter<FileAdapter.Holder>() {

        private val items = mutableListOf<FileItem>()

        fun submit(newItems: List<FileItem>) {
            items.clear()
            items.addAll(newItems)
            notifyDataSetChanged()
        }

        fun currentItems(): List<FileItem> = items.toList()

        override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): Holder =
            Holder(ItemFileBinding.inflate(LayoutInflater.from(parent.context), parent, false))

        override fun getItemCount(): Int = items.size

        override fun onBindViewHolder(holder: Holder, position: Int) {
            holder.bind(items[position])
        }

        inner class Holder(private val binding: ItemFileBinding) :
            RecyclerView.ViewHolder(binding.root) {

            fun bind(item: FileItem) {
                binding.fileName.text = item.name
                binding.fileSubtitle.text = item.subtitle
                binding.root.setOnClickListener { onClick(item) }
                binding.root.setOnLongClickListener {
                    onLongClick(item)
                    true
                }
            }
        }
    }
}
