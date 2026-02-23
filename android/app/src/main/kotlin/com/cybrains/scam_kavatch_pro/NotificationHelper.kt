package com.cybrains.scamkavatchpro

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.os.Build
import androidx.core.app.NotificationCompat

object NotificationHelper {
    // BUG FIX: Change ID to "v2" to force Android to reset channel importance if it was previously low
    private const val CHANNEL_ID = "scam_alerts_channel_v2" 
    private const val NOTIF_ID = 101

    fun showTestNotification(context: Context) {
        showNotification(
            context, 
            "Security Active", 
            "Scam Kavatch is monitoring your device for suspicious links."
        )
    }

    fun showNotification(context: Context, title: String, message: String) {
        val manager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID, 
                "Scam Protection Alerts", 
                NotificationManager.IMPORTANCE_HIGH // Crucial for pop-up behavior
            ).apply {
                description = "Critical alerts for phishing and scam links"
                enableLights(true)
                lightColor = Color.RED
                enableVibration(true)
                // Ensures the alert shows even on the lockscreen
                lockscreenVisibility = NotificationCompat.VISIBILITY_PUBLIC 
                // Bypass DND if you want this to be truly critical
                setBypassDnd(true) 
            }
            manager.createNotificationChannel(channel)
        }

        // Create an intent to open the app when the notification is clicked
        val intent = context.packageManager.getLaunchIntentForPackage(context.packageName)
        val pendingIntent = PendingIntent.getActivity(
            context, 0, intent, 
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val builder = NotificationCompat.Builder(context, CHANNEL_ID)
            .setSmallIcon(android.R.drawable.stat_sys_warning) 
            .setContentTitle(title)
            .setContentText(message)
            .setStyle(NotificationCompat.BigTextStyle().bigText(message))
            .setColor(Color.parseColor("#D32F2F")) 
            .setColorized(true) 
            .setContentIntent(pendingIntent) // User can click to open app
            .setPriority(NotificationCompat.PRIORITY_MAX) // Use MAX for scam alerts
            .setCategory(NotificationCompat.CATEGORY_ALARM)
            .setAutoCancel(true)
            .setOnlyAlertOnce(false) // Set to false so every alert makes noise
            .setDefaults(NotificationCompat.DEFAULT_ALL) 

        manager.notify(NOTIF_ID, builder.build())
    }
}