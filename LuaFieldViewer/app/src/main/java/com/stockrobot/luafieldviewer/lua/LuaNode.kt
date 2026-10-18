package com.stockrobot.luafieldviewer.lua

/** Тип значения скалярного поля (определяется по разобранному литералу). */
enum class ValueType { NUMBER, STRING, BOOLEAN, NIL }

/**
 * Узел разобранной Lua-таблицы. [key] — ключ в родительской таблице
 * (для корня — имя переменной, например `a`).
 */
sealed class LuaNode(val key: String)

/**
 * Скалярное поле.
 * [value] — разобранное значение: Double, String, Boolean или null (nil);
 * [raw] — исходный текст значения из файла (для чисел отображается как есть,
 * например `77762.0` или `-95.742660249554`).
 */
class LuaScalar(key: String, val value: Any?, val raw: String) : LuaNode(key) {

    val type: ValueType = when (value) {
        is Double -> ValueType.NUMBER
        is String -> ValueType.STRING
        is Boolean -> ValueType.BOOLEAN
        else -> ValueType.NIL
    }

    /** Текст значения для отображения/копирования. */
    fun valueText(): String = when (type) {
        ValueType.STRING -> value as? String ?: ""
        ValueType.NUMBER, ValueType.BOOLEAN -> raw
        ValueType.NIL -> "nil"
    }
}

/** Таблица: массив вложенных узлов. */
class LuaTable(key: String, val children: List<LuaNode>) : LuaNode(key) {

    /** true, если все ключи — целые числа (таблица выглядит как массив). */
    val isArray: Boolean =
        children.isNotEmpty() && children.all { it.key.toIntOrNull() != null }
}
