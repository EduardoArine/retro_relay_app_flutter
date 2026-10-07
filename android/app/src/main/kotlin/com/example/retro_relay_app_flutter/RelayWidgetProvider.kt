package com.example.retro_relay_app_flutter

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import java.net.HttpURLConnection
import java.net.URL

class RelayWidgetProvider : AppWidgetProvider() {

    companion object {
        const val ACTION_TOGGLE = "com.example.retro_relay_app_flutter.TOGGLE_CANAL"
        const val EXTRA_CANAL = "canal_index"
        private const val PREFS_NAME = "FlutterSharedPreferences"
        private const val KEY_IP = "flutter.ip_relay"

        // IDs dos botões em ordem (canal 0–7)
        private val BUTTON_IDS = intArrayOf(
            R.id.btn_canal_0, R.id.btn_canal_1, R.id.btn_canal_2, R.id.btn_canal_3,
            R.id.btn_canal_4, R.id.btn_canal_5, R.id.btn_canal_6, R.id.btn_canal_7
        )

        // Cores: ativo = verde, inativo = cinza translúcido
        private const val COLOR_ATIVO = 0xFF4CAF50.toInt()
        private const val COLOR_INATIVO = 0x44FFFFFF

        fun updateAllWidgets(context: Context) {
            val manager = AppWidgetManager.getInstance(context)
            val ids = manager.getAppWidgetIds(
                ComponentName(context, RelayWidgetProvider::class.java)
            )
            if (ids.isNotEmpty()) {
                RelayWidgetProvider().onUpdate(context, manager, ids)
            }
        }
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val ip = prefs.getString(KEY_IP, "192.168.4.1") ?: "192.168.4.1"

        for (widgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.relay_widget)

            for (i in BUTTON_IDS.indices) {
                val isAtivo = prefs.getBoolean("flutter.canal_ativo_$i", false)
                val nomeSalvo = prefs.getString("flutter.canal_nome_$i", null)
                val label = nomeSalvo?.takeIf { it.isNotEmpty() } ?: "${i + 1}"

                views.setTextViewText(BUTTON_IDS[i], label)
                views.setInt(
                    BUTTON_IDS[i], "setBackgroundColor",
                    if (isAtivo) COLOR_ATIVO else COLOR_INATIVO
                )

                val intent = Intent(context, RelayWidgetProvider::class.java).apply {
                    action = ACTION_TOGGLE
                    putExtra(EXTRA_CANAL, i)
                    putExtra("ip", ip)
                }
                val pending = PendingIntent.getBroadcast(
                    context, i, intent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
                views.setOnClickPendingIntent(BUTTON_IDS[i], pending)
            }

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)

        if (intent.action == ACTION_TOGGLE) {
            val canal = intent.getIntExtra(EXTRA_CANAL, -1)
            val ip = intent.getStringExtra("ip") ?: "192.168.4.1"

            if (canal < 0) return

            // Toggle estado local imediatamente
            val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            val atual = prefs.getBoolean("flutter.canal_ativo_$canal", false)
            prefs.edit().putBoolean("flutter.canal_ativo_$canal", !atual).apply()

            // Chama ESP32 em background
            CoroutineScope(Dispatchers.IO).launch {
                try {
                    val url = URL("http://$ip/ligar?canal=$canal")
                    val conn = url.openConnection() as HttpURLConnection
                    conn.connectTimeout = 3000
                    conn.readTimeout = 3000
                    conn.connect()
                    conn.disconnect()
                } catch (_: Exception) {
                    // Reverte se falhar
                    prefs.edit().putBoolean("flutter.canal_ativo_$canal", atual).apply()
                }
                updateAllWidgets(context)
            }

            updateAllWidgets(context)
        }
    }
}
