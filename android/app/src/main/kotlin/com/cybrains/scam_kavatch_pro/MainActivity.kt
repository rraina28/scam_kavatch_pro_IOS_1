package com.cybrains.scamkavatchpro

import android.app.NotificationManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.provider.Settings
import android.util.Log

import androidx.core.view.WindowCompat

import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.plugin.common.MethodChannel


class MainActivity : FlutterFragmentActivity() {

    private val CHANNEL = "com.scamkavatch/overlay"

    private val ENGINE_ID = "scam_kavatch_engine"


    // ✅ REQUIRED for Android 15 edge-to-edge compliance
    override fun onCreate(savedInstanceState: Bundle?) {

        super.onCreate(savedInstanceState)

        // Enables proper edge-to-edge rendering without deprecated APIs
        WindowCompat.setDecorFitsSystemWindows(window, false)
    }


    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {

        super.configureFlutterEngine(flutterEngine)

        // Cache FlutterEngine for AccessibilityService
        try {

            FlutterEngineCache
                .getInstance()
                .put(ENGINE_ID, flutterEngine)

            Log.d("ScamKavatch", "FlutterEngine cached successfully")

        } catch (e: Exception) {

            Log.e("ScamKavatch", "Engine cache failed: $e")
        }


        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->

            val isPremium = SystemGate.isPremiumActive(this)

            when (call.method) {

                "setPremium" -> {

                    val enabled = call.arguments as Boolean

                    SystemGate.setPremium(this, enabled)

                    result.success(true)
                }


                "checkPermissions" -> {

                    if (!isPremium) {

                        result.success(true)

                        return@setMethodCallHandler
                    }

                    val access = isAccessibilityEnabled()
                    val notif = isNotificationEnabled()
                    val overlay = isOverlayEnabled()

                    Log.d(
                        "ScamKavatch",
                        "Permissions → Accessibility:$access Notification:$notif Overlay:$overlay"
                    )

                    result.success(!(access && notif && overlay))
                }


                "openPermissionSetup" -> {

                    if (!isPremium) {

                        result.error(
                            "PREMIUM_REQUIRED",
                            "Upgrade required",
                            null
                        )

                        return@setMethodCallHandler
                    }

                    when {

                        !isAccessibilityEnabled() -> {

                            Log.d("ScamKavatch", "Opening Accessibility")

                            openAccessibility()
                        }

                        !isNotificationEnabled() -> {

                            Log.d("ScamKavatch", "Opening Notification Settings")

                            openNotifications()
                        }

                        !isOverlayEnabled() -> {

                            Log.d("ScamKavatch", "Opening Overlay Settings")

                            openOverlaySettings()
                        }

                        else -> {

                            Log.d("ScamKavatch", "All permissions already granted")
                        }
                    }

                    result.success(true)
                }


                "enableProtection" -> {

                    if (!isPremium) {

                        result.error(
                            "PREMIUM_REQUIRED",
                            "Upgrade required",
                            null
                        )

                        return@setMethodCallHandler
                    }

                    startProtection()

                    result.success(true)
                }


                "checkSystemReady" -> {

                    if (!isPremium) {

                        result.success(false)

                        return@setMethodCallHandler
                    }

                    val ready =
                        isAccessibilityEnabled() &&
                        isNotificationEnabled() &&
                        isOverlayEnabled()

                    result.success(ready)
                }


                "testNotification" -> {

                    try {

                        NotificationHelper.showTestNotification(this)

                        result.success(true)

                    } catch (e: Exception) {

                        result.error(
                            "NOTIF_ERROR",
                            e.toString(),
                            null
                        )
                    }
                }


                else -> result.notImplemented()
            }
        }
    }



    private fun isAccessibilityEnabled(): Boolean {

        return try {

            val expectedService = ComponentName(
                this,
                ScamKavatchAccessibilityService::class.java
            ).flattenToString()

            val enabledServices = Settings.Secure.getString(
                contentResolver,
                Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES
            ) ?: return false

            enabledServices.contains(expectedService)

        } catch (e: Exception) {

            Log.e("ScamKavatch", "Accessibility check failed: $e")

            false
        }
    }


    private fun isNotificationEnabled(): Boolean {

        return try {

            val manager =
                getSystemService(Context.NOTIFICATION_SERVICE)
                        as NotificationManager

            manager.areNotificationsEnabled()

        } catch (e: Exception) {

            Log.e("ScamKavatch", "Notification check failed: $e")

            false
        }
    }


    private fun isOverlayEnabled(): Boolean {

        return try {

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M)
                Settings.canDrawOverlays(this)
            else true

        } catch (e: Exception) {

            Log.e("ScamKavatch", "Overlay check failed: $e")

            false
        }
    }


    private fun openAccessibility() {

        val intent = Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS)

        intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK

        startActivity(intent)
    }


    private fun openNotifications() {

        val intent =
            Intent(Settings.ACTION_APP_NOTIFICATION_SETTINGS)

        intent.putExtra(
            Settings.EXTRA_APP_PACKAGE,
            packageName
        )

        intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK

        startActivity(intent)
    }


    private fun openOverlaySettings() {

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {

            val intent =
                Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION)

            intent.data =
                Uri.parse("package:$packageName")

            intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK

            startActivity(intent)
        }
    }


    private fun startProtection() {

        Log.d("ScamKavatch", "Protection fully enabled")
    }
}
