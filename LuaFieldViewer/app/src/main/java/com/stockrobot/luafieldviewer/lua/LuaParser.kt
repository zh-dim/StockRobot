package com.stockrobot.luafieldviewer.lua

import kotlin.math.abs
import kotlin.math.floor

/** Результат разбора файла: дерево корневой таблицы + сводка. */
data class ParseResult(
    val root: LuaTable,
    val fieldCount: Int,
    val tableCount: Int,
    val maxDepth: Int
)

/**
 * Ошибка разбора с позицией в файле.
 * [reason] — причина, [line]/[column] — позиция (считается с единицы),
 * [snippet] — фрагмент строки с местом ошибки.
 */
class LuaParseException(
    val reason: String,
    val line: Int,
    val column: Int,
    val snippet: String
) : Exception(reason)

/**
 * Разбор Lua-сериализованных таблиц вида
 * ```
 * local a = {
 *    ['ключ']=значение,
 *    ['вложен']={ ['x']=1.5, ['s']='abc' },
 *    [1]={ ... },            -- индексы массивов
 *    bare=2,                 -- «голые» ключи
 * }
 * return a
 * ```
 *
 * Поддерживаются литералы: числа (десятичные, с экспонентой, hex),
 * строки '...' / "..." / [[...]], true/false/nil, вложенные таблицы;
 * разделители `,` и `;`; комментарии `--` и `--[[ ... ]]`.
 * Выражения (арифметика, вызовы функций) не разбираются — это данные, а не код.
 */
object LuaParser {

    @Throws(LuaParseException::class)
    fun parse(text: String): ParseResult = Parser(text).parseChunk()

    // ---- внутреннее представление выражений ----
    private sealed class Expr {
        class Scalar(val value: Any?, val raw: String) : Expr()
        class Table(val children: List<LuaNode>) : Expr()
    }

    private class Parser(private val s: String) {

        private var i = 0
        private var fieldCount = 0
        private var tableCount = 0
        private var maxDepth = 0

        // ================= вход =================
        fun parseChunk(): ParseResult {
            skipWs()
            var root: LuaTable? = null
            var rootName = "a"
            while (i < s.length) {
                if (tryKeyword("return")) {
                    skipWs()
                    if (root == null) {
                        val expr = parseExpr(1)
                        if (expr !is Expr.Table) fail("после return ожидалась таблица")
                        root = LuaTable(rootName, expr.children)
                    }
                    break // возможный хвост после return игнорируем
                }
                tryKeyword("local")
                skipWs()
                val name = tryIdent()
                    ?: fail("ожидалось 'local', 'return' или имя переменной")
                rootName = name
                skipWs()
                if (i >= s.length || s[i] != '=') {
                    fail("ожидалось '=' после имени переменной '$name'")
                }
                i++
                val expr = parseExpr(1)
                if (root == null && expr is Expr.Table) {
                    root = LuaTable(name, expr.children)
                }
                skipWs()
            }
            val result = root
                ?: fail("не найдена Lua-таблица вида 'local a = { ... } return a'")
            return ParseResult(result, fieldCount, tableCount, maxDepth)
        }

        // ================= лексика =================
        private fun skipWs() {
            while (i < s.length) {
                val c = s[i]
                when {
                    c.isWhitespace() -> i++
                    c == '-' && i + 1 < s.length && s[i + 1] == '-' -> {
                        i += 2
                        val lvl = longBracketLevel()
                        if (lvl >= 0) {
                            skipLongBracket(lvl)
                        } else {
                            while (i < s.length && s[i] != '\n') i++
                        }
                    }
                    else -> return
                }
            }
        }

        /** Уровень длинной скобки `[=[` на текущей позиции, либо -1. */
        private fun longBracketLevel(): Int {
            if (i >= s.length || s[i] != '[') return -1
            var j = i + 1
            while (j < s.length && s[j] == '=') j++
            return if (j < s.length && s[j] == '[') j - (i + 1) else -1
        }

        private fun skipLongBracket(level: Int) {
            i += 1 + level // пропускаем [ и '=' * level
            val closer = "]" + "=".repeat(level) + "]"
            val idx = s.indexOf(closer, i)
            if (idx < 0) fail("незакрытый длинный комментарий/строка")
            i = idx + closer.length
        }

        private fun isIdentStart(c: Char) = c.isLetter() || c == '_'
        private fun isIdentPart(c: Char) = c.isLetterOrDigit() || c == '_'

        private fun tryIdent(): String? {
            if (i >= s.length || !isIdentStart(s[i])) return null
            var j = i + 1
            while (j < s.length && isIdentPart(s[j])) j++
            val ident = s.substring(i, j)
            i = j
            return ident
        }

        private fun tryKeyword(kw: String): Boolean {
            if (i + kw.length <= s.length && s.regionMatches(i, kw, 0, kw.length)) {
                val end = i + kw.length
                if (end >= s.length || !isIdentPart(s[end])) {
                    i = end
                    return true
                }
            }
            return false
        }

        // ================= значения =================
        private fun parseExpr(depth: Int): Expr {
            skipWs()
            if (i >= s.length) fail("неожиданный конец файла: ожидалось значение")
            val c = s[i]
            return when {
                c == '{' -> parseTable(depth)
                c == '\'' || c == '"' -> parseQuotedString()
                c == '[' && longBracketLevel() == 0 -> {
                    val start = i
                    skipLongBracket(0)
                    val raw = s.substring(start, i)
                    Expr.Scalar(raw, raw)
                }
                c == '-' || c.isDigit() ||
                    (c == '.' && i + 1 < s.length && s[i + 1].isDigit()) -> parseNumber()
                isIdentStart(c) -> {
                    val mark = i
                    val ident = tryIdent()
                    when (ident) {
                        "true" -> Expr.Scalar(true, "true")
                        "false" -> Expr.Scalar(false, "false")
                        "nil" -> Expr.Scalar(null, "nil")
                        else -> {
                            i = mark
                            fail("выражение не поддерживается (ожидался литерал, найдено '$ident')")
                        }
                    }
                }
                else -> fail("неожиданный символ '$c': ожидалось литеральное значение или таблица")
            }
        }

        private fun parseQuotedString(): Expr.Scalar {
            val quote = s[i]
            val start = i
            i++
            val out = StringBuilder()
            while (i < s.length) {
                val ch = s[i]
                if (ch == quote) {
                    i++
                    return Expr.Scalar(out.toString(), s.substring(start, i))
                }
                if (ch == '\\') {
                    if (i + 1 >= s.length) fail("незакрытая строка")
                    val e = s[i + 1]
                    val simple = when (e) {
                        'n' -> '\n'
                        't' -> '\t'
                        'r' -> '\r'
                        'b' -> '\b'
                        'f' -> '\u000C'
                        'a' -> '\u0007'
                        'v' -> '\u000B'
                        '\\' -> '\\'
                        '\'' -> '\''
                        '"' -> '"'
                        '\n' -> '\n'
                        else -> null
                    }
                    when {
                        simple != null -> {
                            out.append(simple)
                            i += 2
                        }
                        e.isDigit() -> { // десятичный escape, максимум 3 цифры
                            var j = i + 1
                            val num = StringBuilder()
                            while (j < s.length && s[j].isDigit() && num.length < 3) {
                                num.append(s[j])
                                j++
                            }
                            out.append(num.toString().toInt().toChar())
                            i = j
                        }
                        e == 'x' && i + 3 < s.length -> {
                            val hex = s.substring(i + 2, i + 4).toIntOrNull(16)
                            if (hex != null) {
                                out.append(hex.toChar())
                                i += 4
                            } else {
                                out.append(e)
                                i += 2
                            }
                        }
                        else -> { // неизвестный escape — буквально
                            out.append(e)
                            i += 2
                        }
                    }
                    continue
                }
                out.append(ch)
                i++
            }
            fail("незакрытая строка")
        }

        private fun parseNumber(): Expr.Scalar {
            val start = i
            val signLen = if (s[i] == '-') 1 else 0
            val p = i + signLen
            // шестнадцатеричный литерал
            if (p + 1 < s.length && s[p] == '0' && (s[p + 1] == 'x' || s[p + 1] == 'X')) {
                var j = p + 2
                while (j < s.length && (s[j].isDigit() || s[j] in "abcdefABCDEF")) j++
                if (j == p + 2) fail("некорректный шестнадцатеричный номер")
                i = j
                val raw = s.substring(start, j)
                val value = s.substring(p + 2, j).toLongOrNull(16)?.toDouble()
                    ?: fail("некорректное число '$raw'")
                return Expr.Scalar(value, raw)
            }
            // десятичный литерал: целая часть, дробная, экспонента
            var j = start + signLen
            while (j < s.length && s[j].isDigit()) j++
            if (j < s.length && s[j] == '.') {
                j++
                while (j < s.length && s[j].isDigit()) j++
            }
            if (j < s.length && (s[j] == 'e' || s[j] == 'E')) {
                var k = j + 1
                if (k < s.length && (s[k] == '+' || s[k] == '-')) k++
                if (k < s.length && s[k].isDigit()) {
                    while (k < s.length && s[k].isDigit()) k++
                    j = k
                }
            }
            i = j
            val raw = s.substring(start, j)
            val value = raw.toDoubleOrNull() ?: fail("некорректное число '$raw'")
            return Expr.Scalar(value, raw)
        }

        // ================= таблицы =================
        private fun parseTable(depth: Int): Expr.Table {
            i++ // '{'
            tableCount++
            if (depth > maxDepth) maxDepth = depth
            val children = ArrayList<LuaNode>()
            var arrayIndex = 1
            skipWs()
            while (i < s.length && s[i] != '}') {
                val keyRead = readKey(arrayIndex)
                arrayIndex = keyRead.arrayIndex?.plus(1) ?: arrayIndex
                skipWs()
                val expr = parseExpr(depth + 1)
                children += when (expr) {
                    is Expr.Scalar -> {
                        fieldCount++
                        LuaScalar(keyRead.key, expr.value, expr.raw)
                    }
                    is Expr.Table -> LuaTable(keyRead.key, expr.children)
                }
                skipWs()
                if (i < s.length && (s[i] == ',' || s[i] == ';')) {
                    i++
                    skipWs()
                }
            }
            if (i >= s.length) fail("незакрытая таблица: ожидалась '}'")
            i++
            return Expr.Table(children)
        }

        /** Прочитанное поле: явный ключ либо авто-индекс массива. */
        private class KeyRead(val key: String, val arrayIndex: Int?)

        private fun readKey(nextIndex: Int): KeyRead {
            if (i < s.length && s[i] == '[') {
                i++
                skipWs()
                val keyExpr = parseExpr(0)
                skipWs()
                if (i >= s.length || s[i] != ']') fail("ожидалась ']' после ключа")
                i++
                skipWs()
                if (i >= s.length || s[i] != '=') fail("ожидалось '=' после ключа")
                i++
                return KeyRead(keyToString(keyExpr), null)
            }
            val mark = i
            val ident = tryIdent()
            if (ident != null && ident != "true" && ident != "false" && ident != "nil") {
                skipWs()
                if (i < s.length && s[i] == '=') {
                    i++
                    return KeyRead(ident, null)
                }
                i = mark // это значение, а не ключ
            } else if (ident != null) {
                i = mark // true/false/nil — значение
            }
            return KeyRead(nextIndex.toString(), nextIndex)
        }

        private fun keyToString(expr: Expr): String {
            if (expr !is Expr.Scalar) fail("недопустимый тип ключа таблицы")
            return when (val v = expr.value) {
                is String -> v
                is Boolean -> if (v) "true" else "false"
                is Double ->
                    if (v == floor(v) && abs(v) < 1e15) v.toLong().toString() else v.toString()
                else -> fail("ключ не может быть nil")
            }
        }

        // ================= отчёт об ошибке =================
        private fun fail(message: String): Nothing {
            var line = 1
            var column = 1
            val up = i.coerceAtMost(s.length)
            for (k in 0 until up) {
                if (s[k] == '\n') {
                    line++
                    column = 1
                } else {
                    column++
                }
            }
            val before = if (up == 0) -1 else s.lastIndexOf('\n', up - 1)
            val startIdx = if (before < 0) 0 else before + 1
            val after = s.indexOf('\n', up)
            val endIdx = if (after < 0) s.length else after
            val snippet = s.substring(startIdx, minOf(endIdx, startIdx + 120))
            throw LuaParseException(message, line, column, snippet)
        }
    }
}
