package com.stockrobot.luafieldviewer.data

import android.content.Context
import android.net.Uri
import android.provider.OpenableColumns
import java.io.IOException

/** Образец файла, встроенный в APK (assets). */
data class SampleFile(val name: String)

/** Документ, выбранный пользователем через системный выборщик (SAF). */
data class DocumentFile(
    val uri: Uri,
    val name: String,
    val sizeBytes: Long?
)

/**
 * Источники файлов для просмотра:
 *  - встроенные образцы из assets (tool.txt, trends.txt, …);
 *  - документы, выбранные через ACTION_OPEN_DOCUMENT (запоминаются
 *    в SharedPreferences вместе с правом на чтение).
 */
class FileRepository(context: Context) {

    private val appContext = context.applicationContext
    private val prefs = appContext.getSharedPreferences("file_list", Context.MODE_PRIVATE)

    /** Имена встроенных образцов (*.txt в корне assets). */
    fun sampleFiles(): List<SampleFile> = try {
        appContext.assets.list("")
            ?.filter { it.endsWith(".txt", ignoreCase = true) }
            ?.sorted()
            ?.map { SampleFile(it) }
            ?: emptyList()
    } catch (e: Exception) {
        emptyList()
    }

    /** Ранее выбранные пользователем документы. */
    fun documentFiles(): List<DocumentFile> =
        prefs.getStringSet(KEY_DOCUMENTS, emptySet())
            .orEmpty()
            .mapNotNull { raw -> runCatching { Uri.parse(raw) }.getOrNull() }
            .map { uri ->
                DocumentFile(
                    uri = uri,
                    name = displayName(uri) ?: uri.lastPathSegment ?: "документ",
                    sizeBytes = size(uri)
                )
            }
            .sortedBy { it.name.lowercase() }

    fun addDocuments(uris: Collection<Uri>) {
        if (uris.isEmpty()) return
        val current = prefs.getStringSet(KEY_DOCUMENTS, emptySet()).orEmpty().toMutableSet()
        var changed = false
        for (uri in uris) {
            if (current.add(uri.toString())) changed = true
        }
        if (changed) prefs.edit().putStringSet(KEY_DOCUMENTS, current).apply()
    }

    fun removeDocument(uri: Uri) {
        val current = prefs.getStringSet(KEY_DOCUMENTS, emptySet()).orEmpty().toMutableSet()
        if (current.remove(uri.toString())) {
            prefs.edit().putStringSet(KEY_DOCUMENTS, current).apply()
        }
    }

    fun displayName(uri: Uri): String? = try {
        appContext.contentResolver
            .query(uri, arrayOf(OpenableColumns.DISPLAY_NAME), null, null, null)
            ?.use { cursor ->
                if (cursor.moveToFirst() && !cursor.isNull(0)) cursor.getString(0) else null
            }
    } catch (e: Exception) {
        null
    }

    private fun size(uri: Uri): Long? = try {
        appContext.contentResolver
            .query(uri, arrayOf(OpenableColumns.SIZE), null, null, null)
            ?.use { cursor ->
                if (cursor.moveToFirst() && !cursor.isNull(0)) cursor.getLong(0) else null
            }
    } catch (e: Exception) {
        null
    }

    /** Чтение встроенного образца. */
    fun readAsset(name: String): ByteArray =
        appContext.assets.open(name).use { it.readBytes() }

    /** Чтение выбранного документа. */
    fun readDocument(uri: Uri): ByteArray {
        val stream = appContext.contentResolver.openInputStream(uri)
            ?: throw IOException("не удалось открыть $uri")
        return stream.use { it.readBytes() }
    }

    private companion object {
        const val KEY_DOCUMENTS = "documents"
    }
}
