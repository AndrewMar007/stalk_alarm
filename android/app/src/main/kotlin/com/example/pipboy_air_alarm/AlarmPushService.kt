package com.example.pipboy_air_alarm

import android.content.Context
import android.content.Intent
import androidx.core.content.ContextCompat
import com.google.firebase.messaging.FirebaseMessagingService
import com.google.firebase.messaging.RemoteMessage
import java.util.Locale

class AlarmPushService : FirebaseMessagingService() {

  private fun readAppLangCode(): String? {
    // shared_preferences (Flutter) зберігає тут:
    val sp = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
    val raw = sp.getString("flutter.app_locale", null) // "en" / "uk" / null
    val v = raw?.trim()
    return if (v.isNullOrEmpty()) null else v
  }

  private fun isEnglish(): Boolean {
    val saved = readAppLangCode()
    if (saved != null) return saved == "en"
    // якщо мова не задана — беремо системну
    return Locale.getDefault().language == "en"
  }

  override fun onMessageReceived(message: RemoteMessage) {
    val type = message.data["type"] ?: return
    val isStart = type == "ALARM_START"
    val isEnd = type == "ALARM_END"
    if (!isStart && !isEnd) return

    val en = isEnglish()

    val sound = if (isStart) {
      if (en) "alarm_en" else "alarm_uk"
    } else {
      if (en) "alarm_end_en" else "alarm_end_uk"
    }

    val intent = Intent(this, AlarmSoundService::class.java).apply {
      action = AlarmSoundService.ACT_PLAY
      putExtra(AlarmSoundService.EXTRA_SOUND, sound)
    }

    ContextCompat.startForegroundService(this, intent)
  }
}
