package com.stockrobot.luafieldviewer.tree

import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.core.content.ContextCompat
import androidx.recyclerview.widget.RecyclerView
import com.stockrobot.luafieldviewer.R
import com.stockrobot.luafieldviewer.databinding.ItemTreeRowBinding
import com.stockrobot.luafieldviewer.lua.LuaNode
import com.stockrobot.luafieldviewer.lua.LuaScalar
import com.stockrobot.luafieldviewer.lua.LuaTable
import com.stockrobot.luafieldviewer.lua.ValueType

/**
 * Строка плоского списка: в обычном режиме — узел дерева со своим уровнем
 * вложенности, в режиме поиска — совпадение с полным путём.
 */
data class TreeRow(
    val node: LuaNode,
    val depth: Int,
    val displayKey: String,
    val path: String,
    val id: String,
    val expanded: Boolean,
    val searchMode: Boolean
)

/**
 * Адаптер «дерева полей»: корень отображается как список его дочерних полей,
 * таблицы раскрываются/сворачиваются по нажатию, поиск показывает плоский
 * список совпадений с полным путём.
 */
class TreeAdapter(
    private val onScalarClick: (LuaScalar) -> Unit
) : RecyclerView.Adapter<TreeAdapter.Holder>() {

    /** Вызывается после пересчёта строк (нужен экрану для «ничего не найдено»). */
    var onRowsChanged: ((Int) -> Unit)? = null

    private var root: LuaTable? = null
    private var rows: List<TreeRow> = emptyList()
    private val expandedIds = HashSet<String>()
    private var query = ""

    val isSearching: Boolean
        get() = query.isNotEmpty()

    fun setRoot(newRoot: LuaTable) {
        applyRoot(newRoot, keepExpanded = false)
    }

    /**
     * Замена корня при автообновлении файла: раскрытые пользователем узлы
     * сохраняются (узлы, исчезнувшие из новых данных, отбрасываются).
     */
    fun updateRoot(newRoot: LuaTable) {
        applyRoot(newRoot, keepExpanded = true)
    }

    private fun applyRoot(newRoot: LuaTable, keepExpanded: Boolean) {
        root = newRoot
        if (keepExpanded) {
            expandedIds.retainAll(collectTableIds(newRoot))
        } else {
            expandedIds.clear()
            // По умолчанию раскрываем верхний уровень, чтобы поля были видны сразу.
            for (child in newRoot.children) {
                if (child is LuaTable) expandedIds.add(child.key)
            }
        }
        rebuild()
    }

    private fun collectTableIds(table: LuaTable): Set<String> {
        val out = HashSet<String>()
        collectTableIds(table, "", out)
        return out
    }

    private fun collectTableIds(table: LuaTable, prefix: String, out: MutableSet<String>) {
        for (child in table.children) {
            val id = joinId(prefix, child.key)
            if (child is LuaTable) {
                out += id
                collectTableIds(child, id, out)
            }
        }
    }

    fun setQuery(value: String) {
        val normalized = value.trim()
        if (normalized == query) return
        query = normalized
        rebuild()
    }

    private fun rebuild() {
        rows = if (query.isEmpty()) buildVisibleRows() else buildSearchRows()
        notifyDataSetChanged()
        onRowsChanged?.invoke(rows.size)
    }

    // ---------- обычный режим (дерево) ----------
    private fun buildVisibleRows(): List<TreeRow> {
        val rootNode = root ?: return emptyList()
        val out = ArrayList<TreeRow>()
        walkVisible(rootNode, "", "", 0, out)
        return out
    }

    private fun walkVisible(
        table: LuaTable,
        idPrefix: String,
        pathPrefix: String,
        depth: Int,
        out: MutableList<TreeRow>
    ) {
        for (child in table.children) {
            val id = joinId(idPrefix, child.key)
            val display = displayKey(child, table.isArray)
            val path = joinPath(pathPrefix, display)
            val childTable = child as? LuaTable
            if (childTable != null && expandedIds.contains(id)) {
                out += TreeRow(child, depth, display, path, id, true, false)
                walkVisible(childTable, id, path, depth + 1, out)
            } else {
                out += TreeRow(child, depth, display, path, id, false, false)
            }
        }
    }

    // ---------- режим поиска ----------
    private fun buildSearchRows(): List<TreeRow> {
        val rootNode = root ?: return emptyList()
        val q = query.lowercase()
        val out = ArrayList<TreeRow>()
        walkSearch(rootNode, "", "", q, out)
        return out
    }

    private fun walkSearch(
        table: LuaTable,
        idPrefix: String,
        pathPrefix: String,
        q: String,
        out: MutableList<TreeRow>
    ) {
        for (child in table.children) {
            val id = joinId(idPrefix, child.key)
            val display = displayKey(child, table.isArray)
            val path = joinPath(pathPrefix, display)
            if (matches(child, q)) {
                out += TreeRow(child, 0, display, path, id, false, true)
            }
            if (child is LuaTable) {
                walkSearch(child, id, path, q, out)
            }
        }
    }

    private fun matches(node: LuaNode, q: String): Boolean {
        if (node.key.contains(q, ignoreCase = true)) return true
        val scalar = node as? LuaScalar ?: return false
        return scalar.raw.contains(q, ignoreCase = true) ||
            scalar.valueText().contains(q, ignoreCase = true)
    }

    private fun joinId(prefix: String, key: String): String =
        if (prefix.isEmpty()) key else prefix + ID_SEP + key

    private fun joinPath(prefix: String, display: String): String =
        if (prefix.isEmpty()) display else "$prefix › $display"

    /** Отображение ключа: элементы массивов показываются как [1], [2], … */
    private fun displayKey(node: LuaNode, parentIsArray: Boolean): String =
        if (parentIsArray && node.key.toIntOrNull() != null) "[${node.key}]" else node.key

    // ---------- RecyclerView ----------
    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): Holder =
        Holder(ItemTreeRowBinding.inflate(LayoutInflater.from(parent.context), parent, false))

    override fun getItemCount(): Int = rows.size

    override fun onBindViewHolder(holder: Holder, position: Int) {
        holder.bind(rows[position])
    }

    inner class Holder(private val binding: ItemTreeRowBinding) :
        RecyclerView.ViewHolder(binding.root) {

        fun bind(row: TreeRow) {
            val context = binding.root.context
            val padStart = context.dp(12 + row.depth * 16)
            val padEnd = context.dp(16)
            binding.rowMain.setPadding(
                padStart, binding.rowMain.paddingTop, padEnd, binding.rowMain.paddingBottom
            )
            binding.rowPath.setPadding(
                padStart, binding.rowPath.paddingTop, padEnd, binding.rowPath.paddingBottom
            )

            val table = row.node as? LuaTable
            if (table != null && !row.searchMode) {
                binding.rowArrow.visibility = View.VISIBLE
                binding.rowArrow.text = if (row.expanded) "▾" else "▸"
            } else {
                binding.rowArrow.visibility = View.GONE
            }

            binding.rowKey.text = row.displayKey

            if (table != null) {
                val count = table.children.size
                binding.rowValue.text = if (table.isArray) {
                    context.getString(
                        R.string.array_badge,
                        context.resources.getQuantityString(R.plurals.elements, count, count)
                    )
                } else {
                    context.getString(
                        R.string.table_badge,
                        context.resources.getQuantityString(R.plurals.fields, count, count)
                    )
                }
                binding.rowValue.setTextColor(ContextCompat.getColor(context, R.color.subtitle))
            } else {
                val scalar = row.node as LuaScalar
                binding.rowValue.text = scalar.valueText()
                binding.rowValue.setTextColor(
                    ContextCompat.getColor(
                        context,
                        when (scalar.type) {
                            ValueType.NUMBER -> R.color.value_number
                            ValueType.STRING -> R.color.value_string
                            ValueType.BOOLEAN -> R.color.value_boolean
                            ValueType.NIL -> R.color.value_nil
                        }
                    )
                )
            }

            if (row.searchMode) {
                binding.rowPath.visibility = View.VISIBLE
                binding.rowPath.text = row.path
            } else {
                binding.rowPath.visibility = View.GONE
            }

            binding.root.setOnClickListener {
                val node = row.node
                when {
                    node is LuaScalar -> onScalarClick(node)
                    node is LuaTable && !row.searchMode -> {
                        if (!expandedIds.remove(row.id)) expandedIds.add(row.id)
                        rebuild()
                    }
                }
            }
        }
    }

    private companion object {
        const val ID_SEP = "\u0001"
    }
}

private fun Context.dp(value: Int): Int =
    (value * resources.displayMetrics.density).toInt()
