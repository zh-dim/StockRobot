package com.stockrobot.luafieldviewer.net

import java.io.IOException
import java.net.HttpURLConnection
import java.net.URI
import java.net.URL
import java.net.URLDecoder
import java.net.URLEncoder

/** Файл на сервере. */
data class RemoteFile(val name: String, val sizeBytes: Long? = null)

/** Содержимое файла и момент последнего изменения (мс; 0 — неизвестно). */
class RemoteContent(val bytes: ByteArray, val lastModified: Long)

class RemoteServerException(message: String, cause: Throwable? = null) :
    IOException(message, cause)

/**
 * Клиент HTTP-сервера с обычным перечислением каталога
 * (nginx autoindex, Apache, IIS, python -m http.server и т.п.).
 *
 *  - listFiles() — ссылки индексной страницы каталога как файлы
 *    (поддерживаются и относительные, и абсолютные href);
 *  - readFile() — скачивание файла; при переданном If-Modified-Since
 *    возвращает null, если сервер ответил 304 (файл не менялся).
 */
class RemoteServerClient(
    private val baseUrl: String,
    private val connectTimeoutMs: Int = 5_000,
    private val readTimeoutMs: Int = 15_000
) {

    /** Файлы каталога (без подкаталогов), отсортированные по имени. */
    fun listFiles(): List<RemoteFile> {
        val conn = open(baseUrl)
        try {
            checkSuccess(conn)
            val charset = charsetFrom(conn.contentType)
            val body = conn.inputStream.readBytes().toString(charset)
            return parseLinks(body)
        } finally {
            conn.disconnect()
        }
    }

    /**
     * Чтение файла. Возвращает null, если файл не менялся с прошлого раза
     * (сервер ответил 304 Not Modified).
     */
    fun readFile(name: String, ifModifiedSince: Long): RemoteContent? {
        val conn = open(baseUrl + encodePathSegment(name))
        try {
            if (ifModifiedSince > 0) {
                conn.ifModifiedSince = ifModifiedSince
            }
            val code = conn.responseCode
            return when {
                code == HttpURLConnection.HTTP_NOT_MODIFIED -> null
                code in 200..299 ->
                    RemoteContent(conn.inputStream.readBytes(), conn.lastModified)
                else -> throw RemoteServerException("HTTP $code")
            }
        } finally {
            conn.disconnect()
        }
    }

    private fun open(url: String): HttpURLConnection {
        val connection = try {
            URL(url).openConnection() as HttpURLConnection
        } catch (e: Exception) {
            throw RemoteServerException("не удалось открыть $url", e)
        }
        connection.connectTimeout = connectTimeoutMs
        connection.readTimeout = readTimeoutMs
        connection.instanceFollowRedirects = true
        connection.setRequestProperty("Accept", "*/*")
        return connection
    }

    private fun checkSuccess(conn: HttpURLConnection) {
        val code = conn.responseCode
        if (code !in 200..299) throw RemoteServerException("HTTP $code")
    }

    private fun encodePathSegment(name: String): String =
        URLEncoder.encode(name, "UTF-8").replace("+", "%20")

    private fun charsetFrom(contentType: String?): java.nio.charset.Charset {
        if (contentType != null) {
            val marker = "charset="
            val index = contentType.indexOf(marker, ignoreCase = true)
            if (index >= 0) {
                val value = contentType.substring(index + marker.length)
                    .substringBefore(';').trim().trim('"')
                runCatching { java.nio.charset.Charset.forName(value) }
                    .getOrNull()?.let { return it }
            }
        }
        return Charsets.ISO_8859_1 // индексные страницы каталогов — обычно ASCII
    }

    /** Разбор ссылок индексной страницы каталога. */
    private fun parseLinks(html: String): List<RemoteFile> {
        val base = try {
            URI(baseUrl)
        } catch (e: Exception) {
            null
        }
        val basePath = base?.path.orEmpty()

        val href = Regex(
            "<a\\s[^>]*href\\s*=\\s*[\"']([^\"']+)[\"'][^>]*>(.*?)</a>",
            setOf(RegexOption.IGNORE_CASE, RegexOption.DOT_MATCHES_ALL)
        )
        val seen = LinkedHashSet<String>()
        for (match in href.findAll(html)) {
            val rawHref = unescapeHtml(match.groupValues[1]).trim()
            val name = extractFileName(rawHref, base, basePath) ?: continue
            seen += name
        }
        return seen.map { RemoteFile(it) }.sortedBy { it.name.lowercase() }
    }

    /**
     * Из href получаем имя файла каталога; null — ссылка ведёт не в этот
     * каталог или это подкаталог/внешний ресурс.
     */
    private fun extractFileName(href: String, base: URI?, basePath: String): String? {
        if (href.isEmpty()) return null
        if (href.startsWith("#") || href.startsWith("?")) return null

        val raw = href.substringBefore('?').substringBefore('#')
        if (raw.isEmpty()) return null

        // Ссылка внутри каталога: /data/tool.txt → tool.txt
        val path = when {
            raw.contains("://") -> return null            // внешняя ссылка
            raw.startsWith("//") -> return null           // протокол-относительная
            raw.startsWith("/") -> raw                    // абсолютный путь
            base != null -> base.resolve(raw).path.orEmpty()
            else -> raw
        }

        if (basePath.isNotEmpty() && !path.startsWith(basePath)) return null
        if (path.endsWith("/")) return null               // подкаталог
        if (path.contains("://")) return null

        val segment = path.removePrefix(basePath).substringAfterLast('/')
        if (segment.isEmpty() || segment == "." || segment == "..") return null

        val decoded = try {
            URLDecoder.decode(segment, "UTF-8")
        } catch (e: Exception) {
            segment
        }
        if (decoded.isEmpty() || decoded == "." || decoded == "..") return null
        return decoded
    }

    private fun unescapeHtml(text: String): String = text
        .replace("&amp;", "&")
        .replace("&lt;", "<")
        .replace("&gt;", ">")
        .replace("&quot;", "\"")
        .replace("&#39;", "'")
        .replace("&nbsp;", " ")
}
