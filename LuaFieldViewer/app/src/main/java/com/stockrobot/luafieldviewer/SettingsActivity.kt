package com.stockrobot.luafieldviewer

import android.os.Bundle
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import com.stockrobot.luafieldviewer.databinding.ActivitySettingsBinding
import com.stockrobot.luafieldviewer.settings.AppSettings

/**
 * Экран настроек подключения к серверу: адрес (IP), порт, каталог
 * и период автообновления. Значения применяются сразу после сохранения.
 */
class SettingsActivity : AppCompatActivity() {

    private lateinit var binding: ActivitySettingsBinding
    private lateinit var settings: AppSettings

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivitySettingsBinding.inflate(layoutInflater)
        setContentView(binding.root)
        setSupportActionBar(binding.toolbar)
        supportActionBar?.setDisplayHomeAsUpEnabled(true)
        supportActionBar?.title = getString(R.string.settings_title)

        settings = AppSettings(this)

        binding.hostEdit.setText(settings.host)
        binding.portEdit.setText(settings.port.toString())
        binding.pathEdit.setText(settings.path)
        binding.intervalEdit.setText(settings.refreshIntervalSec.toString())
        binding.maskEdit.setText(settings.fileMask)

        binding.saveButton.setOnClickListener { save() }
    }

    override fun onSupportNavigateUp(): Boolean {
        finish()
        return true
    }

    private fun save() {
        val host = binding.hostEdit.text?.toString()?.trim().orEmpty()
        if (host.isEmpty()) {
            binding.hostLayout.error = getString(R.string.settings_host_required)
            return
        }
        binding.hostLayout.error = null

        val port = binding.portEdit.text?.toString()?.toIntOrNull()
        if (port == null || port !in 1..65535) {
            binding.portLayout.error = getString(R.string.settings_port_invalid)
            return
        }
        binding.portLayout.error = null

        val interval = binding.intervalEdit.text?.toString()?.toIntOrNull()
        if (interval == null || interval !in 1..3600) {
            binding.intervalLayout.error = getString(R.string.settings_interval_invalid)
            return
        }
        binding.intervalLayout.error = null

        val path = binding.pathEdit.text?.toString()?.trim().orEmpty()
        val mask = binding.maskEdit.text?.toString()?.trim().orEmpty()

        settings.host = host
        settings.port = port
        settings.path = path
        settings.refreshIntervalSec = interval
        settings.fileMask = mask

        Toast.makeText(this, R.string.settings_saved, Toast.LENGTH_SHORT).show()
        finish()
    }
}
