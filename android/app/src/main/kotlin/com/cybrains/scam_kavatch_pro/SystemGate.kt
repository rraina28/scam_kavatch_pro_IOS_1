package com.cybrains.scamkavatchpro

import android.content.Context
import android.content.SharedPreferences
import android.provider.Settings
import android.content.ComponentName
import android.os.Build
import android.app.NotificationManager

object SystemGate {

    private const val PREF_NAME = "scam_kavatch_prefs"
    private const val KEY_PREMIUM = "premium_enabled"

    private var premiumEnabled: Boolean? = null // Using nullable to detect if not yet loaded

    private fun prefs(context: Context): SharedPreferences {
        return context.getSharedPreferences(PREF_NAME, Context.MODE_PRIVATE)
    }

    // ================= INIT =================
    fun init(context: Context) {
        premiumEnabled = prefs(context).getBoolean(KEY_PREMIUM, false)
    }

    // ================= FROM FLUTTER =================

    fun setPremium(context: Context, enabled: Boolean) {
        premiumEnabled = enabled
        prefs(context).edit().putBoolean(KEY_PREMIUM, enabled).apply()
    }

    /**
     * Self-healing getter: If the variable is null, it fetches from disk immediately.
     */
    fun isPremiumActive(context: Context): Boolean {
        if (premiumEnabled == null) {
            premiumEnabled = prefs(context).getBoolean(KEY_PREMIUM, false)
        }
        return premiumEnabled ?: false
    }

    // ================= MASTER CHECK =================

    /**
     * Determines if the core scanning engine should run.
     * We ONLY block for Premium and Accessibility.
     */
    fun isSystemAllowed(context: Context): Boolean {
        // 1. Ensure premium status is loaded
        if (!isPremiumActive(context)) return false

        // 2. Accessibility Check (Essential for URL detection)
        if (!isAccessibilityEnabled(context)) return false

        // Scanner is allowed to run. 
        // We handle missing Notifications/Overlays inside the Detection logic.
        return true
    }

    // ================= STATUS HELPERS =================

    /**
     * Returns true ONLY if the app can show UI alerts (Notifications + Overlays).
     */
    fun canShowAlerts(context: Context): Boolean {
        val notifs = isNotificationAllowed(context)
        val overlay = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            Settings.canDrawOverlays(context)
        } else true
        
        return notifs && overlay
    }

    // ================= PERMISSION HELPERS =================

    private fun isAccessibilityEnabled(context: Context): Boolean {
        val expectedService = ComponentName(context, ScamKavatchAccessibilityService::class.java).flattenToString()
        val enabled = Settings.Secure.getString(
            context.contentResolver,
            Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES
        ) ?: return false

        return enabled.contains(expectedService)
    }

    fun isNotificationAllowed(context: Context): Boolean {
        return if (Build.VERSION.SDK_INT >= 33) {
            context.checkSelfPermission(
                android.Manifest.permission.POST_NOTIFICATIONS
            ) == android.content.pm.PackageManager.PERMISSION_GRANTED
        } else {
            val manager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            manager.areNotificationsEnabled()
        }
    }
}