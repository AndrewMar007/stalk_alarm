package com.example.pipboy_air_alarm

import android.app.KeyguardManager
import android.content.Context
import android.os.Build
import android.os.Bundle
import android.view.WindowManager
import android.widget.Button
import android.widget.TextView
import androidx.activity.ComponentActivity

class AlarmActivity : ComponentActivity() {

  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)

    // ✅ показ поверх lockscreen + включення екрана
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
      setShowWhenLocked(true)
      setTurnScreenOn(true)
    } else {
      @Suppress("DEPRECATION")
      window.addFlags(
        WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
          WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON or
          WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON
      )
    }

    // ✅ розблокувати (якщо дозволено системою) / просто “пробудити”
    val km = getSystemService(Context.KEYGUARD_SERVICE) as KeyguardManager
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
      km.requestDismissKeyguard(this, null)
    }

    // ✅ layout
    setContentView(R.layout.activity_alarm)

    val title = intent.getStringExtra("title") ?: "Stalk Alarm"
    val body = intent.getStringExtra("body") ?: "Повітряна тривога"

    findViewById<TextView>(R.id.alarmTitle).text = title
    findViewById<TextView>(R.id.alarmBody).text = body

    findViewById<Button>(R.id.btnClose).setOnClickListener { finish() }
    findViewById<Button>(R.id.btnOk).setOnClickListener { finish() }
  }

  override fun onDestroy() {
    super.onDestroy()
    // ✅ прибрати flags для старих Android
    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O_MR1) {
      @Suppress("DEPRECATION")
      window.clearFlags(
        WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
          WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON or
          WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON
      )
    }
  }
}
