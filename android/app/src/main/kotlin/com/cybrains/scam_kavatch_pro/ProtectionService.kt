package com.cybrains.scamkavatchpro

import android.app.*
import android.os.Build
import android.os.IBinder
import androidx.core.app.NotificationCompat

class ProtectionService : Service() {

    override fun onStartCommand(
        intent: android.content.Intent?, flags: Int, startId: Int
    ): Int {

        startForeground(1, createNotification())

        return START_STICKY
    }

    override fun onBind(intent: android.content.Intent?): IBinder? = null


    private fun createNotification(): Notification {

        val channelId = "scam_protection"

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {

            val channel = NotificationChannel(
                channelId,
                "Scam Protection",
                NotificationManager.IMPORTANCE_LOW
            )

            getSystemService(NotificationManager::class.java)
                .createNotificationChannel(channel)
        }

        return NotificationCompat.Builder(this, channelId)
            .setContentTitle("ScamKavatch Active")
            .setContentText("Auto protection running")
            // ✅ Use system icon (no R reference)
            .setSmallIcon(android.R.drawable.ic_lock_idle_lock)
            .build()
    }
}
