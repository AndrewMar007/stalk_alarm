package com.example.pipboy_air_alarm

import android.app.NotificationManager
import android.content.Context
import android.content.Intent
import android.media.AudioManager
import android.os.PowerManager
import android.provider.Settings
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

  private val CHANNEL = "stalk_alarm/alarm"

  // ✅ prefs для “жорсткого mute”
  private val PREFS = "stalk_alarm_prefs"
  private val KEY_ALARM_STEP = "alarm_step"

  private fun prefs() = getSharedPreferences(PREFS, Context.MODE_PRIVATE)

  private fun getSavedAlarmStep(): Int =
    prefs().getInt(KEY_ALARM_STEP, -1) // -1 = ще не задавали

  private fun saveAlarmStep(step: Int) {
    prefs().edit().putInt(KEY_ALARM_STEP, step).apply()
  }

  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)

    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
      .setMethodCallHandler { call, result ->

        when (call.method) {

          // ===============================
          // 🔊 PLAY ALARM SOUND (STREAM_ALARM)
          // ===============================
          "playAlarmSound" -> {
            val sound = call.argument<String>("sound") ?: "alarm"

            // ✅ ЖОРСТКИЙ MUTE:
            // якщо в додатку виставили 0 — не граємо взагалі
            val savedStep = getSavedAlarmStep()
            if (savedStep == 0) {
              // на всяк випадок зупинимо, якщо щось грало
              try {
                val stopIntent = Intent(this, AlarmSoundService::class.java).apply {
                  action = AlarmSoundService.ACT_STOP
                }
                startService(stopIntent)
              } catch (_: Throwable) {}
              result.success(true)
              return@setMethodCallHandler
            }

            val i = Intent(this, AlarmSoundService::class.java).apply {
              action = AlarmSoundService.ACT_PLAY
              putExtra(AlarmSoundService.EXTRA_SOUND, sound)
            }

            ContextCompat.startForegroundService(this, i)
            result.success(true)
          }

          "stopAlarmSound" -> {
            val i = Intent(this, AlarmSoundService::class.java).apply {
              action = AlarmSoundService.ACT_STOP
            }
            startService(i)
            result.success(true)
          }

          // ===============================
          // 💡 WAKE SCREEN (NO UI)
          // ===============================
          "wakeScreen" -> {
            wakeScreen()
            result.success(true)
          }

          // ===============================
          // 🔊 ALARM volume STEPS (cur/max)
          // ===============================
          "getAlarmVolumeSteps" -> {
            val am = getSystemService(Context.AUDIO_SERVICE) as AudioManager
            val max = am.getStreamMaxVolume(AudioManager.STREAM_ALARM)
            val cur = am.getStreamVolume(AudioManager.STREAM_ALARM)
            result.success(mapOf("cur" to cur, "max" to max))
          }

          "setAlarmVolumeSteps" -> {
            val stepArg = (call.argument<Int>("step") ?: 0)

            val am = getSystemService(Context.AUDIO_SERVICE) as AudioManager
            val max = am.getStreamMaxVolume(AudioManager.STREAM_ALARM)
            val target = stepArg.coerceIn(0, max)

            // ✅ зберігаємо для “жорсткого mute”
            saveAlarmStep(target)

            // Показати UI + застосувати
            am.setStreamVolume(
              AudioManager.STREAM_ALARM,
              target,
              AudioManager.FLAG_SHOW_UI
            )

            // ✅ якщо 0 — одразу стопнемо звук
            if (target == 0) {
              val stopIntent = Intent(this, AlarmSoundService::class.java).apply {
                action = AlarmSoundService.ACT_STOP
              }
              startService(stopIntent)
            }

            result.success(true)
          }

          // ===============================
          // 🔔 DND ACCESS
          // ===============================
          "hasDndAccess" -> {
            val nm = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            result.success(nm.isNotificationPolicyAccessGranted)
          }

          "openDndAccessSettings" -> {
            val intent =
              Intent(Settings.ACTION_NOTIFICATION_POLICY_ACCESS_SETTINGS)
                .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            startActivity(intent)
            result.success(true)
          }

          else -> result.notImplemented()
        }
      }
  }

  private fun wakeScreen() {
    val pm = getSystemService(Context.POWER_SERVICE) as PowerManager
    val wakeLock =
      pm.newWakeLock(
        PowerManager.SCREEN_BRIGHT_WAKE_LOCK or
          PowerManager.ACQUIRE_CAUSES_WAKEUP or
          PowerManager.ON_AFTER_RELEASE,
        "stalk_alarm:WAKE"
      )
    wakeLock.acquire(3000)
    wakeLock.release()
  }
}
