package com.example.pipboy_air_alarm

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Context
import android.content.Intent
import android.media.AudioAttributes
import android.media.AudioManager
import android.media.MediaPlayer
import android.net.Uri
import android.os.Build
import android.os.IBinder
import androidx.core.app.NotificationCompat

class AlarmSoundService : Service() {

  companion object {
    private const val CH_ID = "alarm_fgs_channel"
    private const val NOTIF_ID = 9001

    const val ACT_PLAY = "PLAY"
    const val ACT_STOP = "STOP"
    const val EXTRA_SOUND = "sound"
  }

  private var player: MediaPlayer? = null

  override fun onCreate() {
    super.onCreate()
    ensureChannel()
  }

  override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
    when (intent?.action) {

      ACT_PLAY -> {
        val sound = intent.getStringExtra(EXTRA_SOUND) ?: "alarm"

        // ✅ Якщо ALARM volume = 0 → НЕ граємо взагалі (повна тиша)
        if (isAlarmVolumeZero()) {
          stop() // якщо щось грало — зупинити
          stopForeground(STOP_FOREGROUND_REMOVE)
          stopSelf()
          return START_NOT_STICKY
        }

        startForegroundInternal()
        play(sound)
      }

      ACT_STOP -> {
        stop()
        stopForeground(STOP_FOREGROUND_REMOVE)
        stopSelf()
      }
    }
    return START_NOT_STICKY
  }

  private fun isAlarmVolumeZero(): Boolean {
    val am = getSystemService(Context.AUDIO_SERVICE) as AudioManager
    return am.getStreamVolume(AudioManager.STREAM_ALARM) <= 0
  }

  private fun startForegroundInternal() {
    val n: Notification = NotificationCompat.Builder(this, CH_ID)
      .setSmallIcon(android.R.drawable.ic_lock_idle_alarm)
      .setContentTitle("Stalk Alarm")
      .setContentText("Playing alarm…")
      .setOngoing(true)
      .setPriority(NotificationCompat.PRIORITY_MAX)
      .build()

    startForeground(NOTIF_ID, n)
  }

  private fun play(sound: String) {
    stop()

    val resId = resources.getIdentifier(sound, "raw", packageName)
    if (resId == 0) {
      stopForeground(STOP_FOREGROUND_REMOVE)
      stopSelf()
      return
    }

    // ✅ ВАЖЛИВО: не MediaPlayer.create(), а вручну — щоб AudioAttributes застосувались правильно
    val uri = Uri.parse("android.resource://$packageName/$resId")

    player = MediaPlayer().apply {
      setAudioAttributes(
        AudioAttributes.Builder()
          .setUsage(AudioAttributes.USAGE_ALARM)
          .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
          .build()
      )
      setDataSource(this@AlarmSoundService, uri)
      isLooping = false

      setOnCompletionListener {
        stop()
        stopForeground(STOP_FOREGROUND_REMOVE)
        stopSelf()
      }

      prepare()
      start()
    }
  }

  private fun stop() {
    try { player?.stop() } catch (_: Throwable) {}
    try { player?.release() } catch (_: Throwable) {}
    player = null
  }

  private fun ensureChannel() {
    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return

    val nm = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
    val ch = NotificationChannel(
      CH_ID,
      "Alarm playback",
      NotificationManager.IMPORTANCE_HIGH
    )
    nm.createNotificationChannel(ch)
  }

  override fun onDestroy() {
    stop()
    super.onDestroy()
  }

  override fun onBind(intent: Intent?): IBinder? = null
}
