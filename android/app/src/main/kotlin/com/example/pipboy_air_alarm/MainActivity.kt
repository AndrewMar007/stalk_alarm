package com.example.pipboy_air_alarm

import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
  private val CHANNEL = "stalk_alarm/alarm"

  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)

    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
      .setMethodCallHandler { call, result ->
        if (call.method == "openAlarmScreen") {
          val title = call.argument<String>("title") ?: "Stalk Alarm"
          val body = call.argument<String>("body") ?: "Повітряна тривога"

          val i = Intent(this, AlarmActivity::class.java).apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
            putExtra("title", title)
            putExtra("body", body)
          }
          startActivity(i)
          result.success(true)
        } else {
          result.notImplemented()
        }
      }
  }
}
