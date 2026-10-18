package com.stockrobot.luafieldviewer.settings

import android.content.Context

/**
 * Настройки подключения к серверу: адрес (IP или имя), порт, каталог
 * и период автообновления. Хранятся в SharedPreferences.
 */
class AppSettings(context: Context) {

    private val prefs =
        context.applicationContext.getSharedPreferences("app_settings", Context.MODE_PRIVATE)

    /** Адрес сервера: IP или доменное имя, без схемы. */
    var host: String
        get() = prefs.getString(KEY_HOST, "") ?: ""
        set(value) {
            val cleaned = value.trim()
                .removePrefix("http://")
                .removePrefix("https://")
                .trimEnd('/')
            prefs.edit().putString(KEY_HOST, cleaned).apply()
        }

    /** Порт HTTP-сервера. */
    var port: Int
        get() = prefs.getInt(KEY_PORT, DEFAULT_PORT)
        set(value) {
            prefs.edit().putInt(KEY_PORT, value).apply()
        }

    /** Каталог на сервере, например «/data» или «data/quik». */
    var path: String
        get() = prefs.getString(KEY_PATH, "") ?: ""
        set(value) {
            prefs.edit().putString(KEY_PATH, value.trim()).apply()
        }

    /** Период автообновления, секунд. */
    var refreshIntervalSec: Int
        get() = prefs.getInt(KEY_INTERVAL, DEFAULT_INTERVAL_SEC)
        set(value) {
            prefs.edit().putInt(KEY_INTERVAL, value).apply()
        }

    /**
     * Маска файлов каталога: расширения через запятую без точки, например
     * «txt» или «txt,lua». Пусто — показывать все файлы.
     */
    var fileMask: String
        get() = prefs.getString(KEY_MASK, DEFAULT_MASK) ?: DEFAULT_MASK
        set(value) {
            prefs.edit().putString(KEY_MASK, value.trim()).apply()
        }

    /** Подходит ли файл под маску расширений. */
    fun matchesMask(fileName: String): Boolean {
        val extensions = extensionList()
        if (extensions.isEmpty()) return true
        val ext = fileName.substringAfterLast('.', "").lowercase()
        return extensions.any { it == ext }
    }

    /** Список расширений из маски (нижний регистр, без точек). */
    fun extensionList(): List<String> = fileMask
        .split(',', ';', ' ')
        .map { it.trim().removePrefix(".").lowercase() }
        .filter { it.isNotEmpty() }

    /** Заполнен ли адрес сервера. */
    val isConfigured: Boolean
        get() = host.isNotEmpty()

    /**
     * Базовый URL каталога с завершающим слешем:
     * http://192.168.1.10/data/
     */
    fun baseUrl(): String {
        var hostPart = host.trim().trimEnd('/')
        var portPart = port

        // Порт можно указать прямо в адресе: 192.168.1.10:8080
        val colon = hostPart.lastIndexOf(':')
        if (colon > 0) {
            val explicit = hostPart.substring(colon + 1).toIntOrNull()
            if (explicit != null && explicit in 1..65535) {
                portPart = explicit
                hostPart = hostPart.substring(0, colon)
            }
        }

        val portSuffix = if (portPart == DEFAULT_PORT) "" else ":$portPart"
        val trimmedPath = path.trim().trim('/')
        val pathPart = if (trimmedPath.isEmpty()) "" else "/$trimmedPath"
        return "http://$hostPart$portSuffix$pathPart/"
    }

    private companion object {
        const val KEY_HOST = "host"
        const val KEY_PORT = "port"
        const val KEY_PATH = "path"
        const val KEY_INTERVAL = "interval_sec"
        const val KEY_MASK = "file_mask"
        const val DEFAULT_PORT = 80
        const val DEFAULT_INTERVAL_SEC = 5
        const val DEFAULT_MASK = "txt"
    }
}
