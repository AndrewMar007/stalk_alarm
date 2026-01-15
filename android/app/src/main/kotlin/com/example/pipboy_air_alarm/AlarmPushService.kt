package com.example.pipboy_air_alarm

import android.content.Intent
import androidx.core.content.ContextCompat
import com.google.firebase.messaging.FirebaseMessagingService
import com.google.firebase.messaging.RemoteMessage

class AlarmPushService : FirebaseMessagingService() {

  override fun onMessageReceived(message: RemoteMessage) {

    val type = message.data["type"] ?: return
    val sound = when (type) {
      "ALARM_START" -> "alarm"
      "ALARM_END" -> "alarm_end"
      else -> return
    }

    val intent = Intent(this, AlarmSoundService::class.java).apply {
      action = AlarmSoundService.ACT_PLAY
      putExtra(AlarmSoundService.EXTRA_SOUND, sound)
    }

    ContextCompat.startForegroundService(this, intent)
  }
}
