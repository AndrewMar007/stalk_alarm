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
import android.os.PowerManager
import androidx.core.app.NotificationCompat

class AlarmSoundService : Service() {

  companion object {
    private const val CH_ID = "alarm_fgs_channel"
    private const val NOTIF_ID = 9001

    const val ACT_PLAY = "PLAY"
    const val ACT_STOP = "STOP"
    const val EXTRA_SOUND = "sound"

    // ✅ спільні prefs з MainActivity
    private const val PREFS = "stalk_alarm_prefs"
    private const val KEY_ALARM_STEP = "alarm_step" // 0..max, -1 = not set
  }

  private var player: MediaPlayer? = null
  private var wakeLock: PowerManager.WakeLock? = null

  // ✅ запам’ятовуємо системну гучність будильника, щоб повернути назад
  private var prevAlarmVolume: Int? = null

  override fun onCreate() {
    super.onCreate()
    ensureChannel()
  }

  override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
    when (intent?.action) {

      ACT_PLAY -> {
        val sound = intent.getStringExtra(EXTRA_SOUND) ?: "alarm"

        // ✅ якщо в додатку виставили 0 — повна тиша
        val savedStep = getSavedAlarmStep()
        if (savedStep == 0) {
          stopSelf()
          return START_NOT_STICKY
        }

        // ⚡ ПРОБУДИТИ ЕКРАН
        acquireWakeLock()

        startForegroundInternal()

        // ✅ ТИМЧАСОВО піднімаємо гучність будильника (без HUD)
        boostAlarmVolumeTemporarily(savedStep)

        play(sound)
      }

      ACT_STOP -> {
        stop()
        restoreAlarmVolume()
        releaseWakeLock()
        stopForeground(STOP_FOREGROUND_REMOVE)
        stopSelf()
      }
    }
    return START_NOT_STICKY
  }

  // ===============================
  // ⚡ WAKELOCK
  // ===============================
  private fun acquireWakeLock() {
    if (wakeLock?.isHeld == true) return

    val pm = getSystemService(Context.POWER_SERVICE) as PowerManager
    wakeLock = pm.newWakeLock(
      PowerManager.SCREEN_BRIGHT_WAKE_LOCK or
        PowerManager.ACQUIRE_CAUSES_WAKEUP or
        PowerManager.ON_AFTER_RELEASE,
      "stalk_alarm:WAKE"
    )

    wakeLock?.acquire(4000) // 4 секунди — достатньо
  }

  private fun releaseWakeLock() {
    try { wakeLock?.release() } catch (_: Throwable) {}
    wakeLock = null
  }

  // ===============================
  // 🔊 PREFS (app alarm volume step)
  // ===============================
  private fun getSavedAlarmStep(): Int {
    val sp = getSharedPreferences(PREFS, Context.MODE_PRIVATE)
    return sp.getInt(KEY_ALARM_STEP, -1)
  }

  // ===============================
  // 🔊 TEMP BOOST / RESTORE (NO HUD)
  // ===============================
  private fun boostAlarmVolumeTemporarily(savedStep: Int) {
    val am = getSystemService(Context.AUDIO_SERVICE) as AudioManager
    val max = am.getStreamMaxVolume(AudioManager.STREAM_ALARM)

    // запам’ятали системний рівень 1 раз перед підсиленням
    if (prevAlarmVolume == null) {
      prevAlarmVolume = am.getStreamVolume(AudioManager.STREAM_ALARM)
    }

    // якщо savedStep не заданий (-1) — тоді робимо максимум
    val target = if (savedStep >= 0) savedStep.coerceIn(0, max) else max

    // ✅ без HUD: flags = 0
    am.setStreamVolume(AudioManager.STREAM_ALARM, target, 0)
  }

  private fun restoreAlarmVolume() {
    val prev = prevAlarmVolume ?: return
    val am = getSystemService(Context.AUDIO_SERVICE) as AudioManager

    // ✅ без HUD: flags = 0
    am.setStreamVolume(AudioManager.STREAM_ALARM, prev, 0)
    prevAlarmVolume = null
  }

  // ===============================
  // 🔊 AUDIO
  // ===============================
  private fun play(sound: String) {
    stop()

    val resId = resources.getIdentifier(sound, "raw", packageName)
    if (resId == 0) {
      restoreAlarmVolume()
      stopSelf()
      return
    }

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
        restoreAlarmVolume()
        releaseWakeLock()
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

  // ===============================
  // 🔔 FOREGROUND
  // ===============================
  private fun startForegroundInternal() {
    val n: Notification = NotificationCompat.Builder(this, CH_ID)
      .setSmallIcon(R.drawable.ic_radiation)
      .setContentTitle(getString(R.string.app_name))
      .setContentText(getString(R.string.alarm_active))
      .setOngoing(true)
      .setSilent(true)
      .setOnlyAlertOnce(true)
      .setPriority(NotificationCompat.PRIORITY_HIGH)
      .build()

    startForeground(NOTIF_ID, n)
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
    restoreAlarmVolume()
    releaseWakeLock()
    super.onDestroy()
  }

  override fun onBind(intent: Intent?): IBinder? = null
}
