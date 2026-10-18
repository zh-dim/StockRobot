package com.stockrobot.luafieldviewer.data

import java.nio.ByteBuffer
import java.nio.charset.CharacterCodingException
import java.nio.charset.CodingErrorAction

/**
 * Декодирование байтов файла в текст.
 * Файлы QUIK/StockRobot могут быть в UTF-8 (по умолчанию) или windows-1251;
 * BOM учитывается. Строгая проверка UTF-8: если байты не являются корректным
 * UTF-8 — используется windows-1251.
 */
object TextDecoder {

    fun decode(bytes: ByteArray): String {
        if (hasBom(bytes, 0xEF, 0xBB, 0xBF)) {
            return String(bytes, 3, bytes.size - 3, Charsets.UTF_8)
        }
        if (hasBom(bytes, 0xFF, 0xFE)) {
            return String(bytes, 2, bytes.size - 2, charset("UTF-16LE"))
        }
        if (hasBom(bytes, 0xFE, 0xFF)) {
            return String(bytes, 2, bytes.size - 2, charset("UTF-16BE"))
        }
        return try {
            Charsets.UTF_8.newDecoder()
                .onMalformedInput(CodingErrorAction.REPORT)
                .onUnmappableCharacter(CodingErrorAction.REPORT)
                .decode(ByteBuffer.wrap(bytes))
                .toString()
        } catch (e: CharacterCodingException) {
            runCatching { String(bytes, charset("windows-1251")) }
                .getOrElse { String(bytes, Charsets.UTF_8) }
        }
    }

    private fun hasBom(bytes: ByteArray, vararg bom: Int): Boolean {
        if (bytes.size < bom.size) return false
        for (idx in bom.indices) {
            if (bytes[idx] != bom[idx].toByte()) return false
        }
        return true
    }
}
