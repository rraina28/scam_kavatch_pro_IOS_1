package com.cybrains.scamkavatchpro

import android.accessibilityservice.AccessibilityService
import android.accessibilityservice.AccessibilityServiceInfo
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.view.accessibility.AccessibilityEvent
import android.view.accessibility.AccessibilityNodeInfo
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodChannel

class ScamKavatchAccessibilityService : AccessibilityService() {

    private val TAG = "ScamKavatchService"
    private val CHANNEL = "scam_kavatch/accessibility"

    private val handler = Handler(Looper.getMainLooper())

    private var methodChannel: MethodChannel? = null

    // Alert Throttling
    private var lastDetectedUrl = ""
    private var lastAlertTime = 0L

    private val ALERT_COOLDOWN = 3000L

    // Supported apps ONLY
    private val supportedPackages = setOf(
        "com.android.chrome",
        "com.whatsapp",
        "com.facebook.orca",
        "com.sec.android.app.sbrowser"
    )

    private val suspiciousHosts = setOf(
        "sites.google.com",
        "blogspot.com",
        "weebly.com",
        "pages.dev",
        "vercel.app"
    )

    private val suspiciousKeywords = setOf(
        "refund",
        "claim",
        "upi",
        "kyc",
        "verify",
        "bank",
        "secure",
        "login",
        "offer"
    )

    private val suspiciousTlds = setOf(
        "xyz",
        "top",
        "click",
        "site",
        "link",
        "online",
        "abc",
        "icu",
        "buzz"
    )

    enum class RiskLevel {
        LOW,
        MEDIUM,
        HIGH
    }

    override fun onServiceConnected() {

        super.onServiceConnected()

        serviceInfo = serviceInfo?.apply {

            flags = flags or
                    AccessibilityServiceInfo.FLAG_REPORT_VIEW_IDS or
                    AccessibilityServiceInfo.FLAG_RETRIEVE_INTERACTIVE_WINDOWS or
                    AccessibilityServiceInfo.FLAG_INCLUDE_NOT_IMPORTANT_VIEWS
        }

        initFlutter()

        Log.d(TAG, "Service Connected & Optimized")
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {

        if (event == null) return

        // IMPORTANT FIX: Only react to relevant events
        if (event.eventType != AccessibilityEvent.TYPE_WINDOW_CONTENT_CHANGED &&
            event.eventType != AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED
        ) {
            return
        }

        if (!SystemGate.isSystemAllowed(this)) return

        val pkg = event.packageName?.toString() ?: return

        if (!supportedPackages.contains(pkg)) return

        handler.removeCallbacks(scanRunnable)

        handler.postDelayed(scanRunnable, 500)
    }

    private val scanRunnable = Runnable {

        val root = rootInActiveWindow ?: return@Runnable

        try {

            val urls = mutableSetOf<String>()

            performSafeScan(root, urls)

            for (url in urls) {

                val risk = calculateRisk(url)

                if (risk != RiskLevel.LOW && !shouldIgnore(url)) {

                    handleThreat(url, risk)
                }
            }

        } catch (e: Exception) {

            Log.e(TAG, "Scan Error", e)

        } finally {

            root.recycle()
        }
    }

    private fun performSafeScan(
        node: AccessibilityNodeInfo?,
        results: MutableSet<String>
    ) {

        if (node == null) return

        val pkg = node.packageName?.toString()

        // IMPORTANT FIX: strict package validation
        if (pkg == null || !supportedPackages.contains(pkg)) return

        // Chrome URL bar detection
        if (pkg == "com.android.chrome" &&
            (node.viewIdResourceName?.contains("url_bar") == true ||
             node.viewIdResourceName?.contains("location_bar") == true)
        ) {

            node.text?.toString()?.let {

                results.add(it.lowercase().trim())
            }
        }

        // General URL detection
        node.text?.toString()?.let {

            results.addAll(extractUrls(it))
        }

        for (i in 0 until node.childCount) {

            val child = node.getChild(i) ?: continue

            performSafeScan(child, results)

            child.recycle()
        }
    }

    private fun extractUrls(text: String): List<String> {

        val regex =
            """\b([a-zA-Z0-9][a-zA-Z0-9-]{0,61}[a-zA-Z0-9]\.)+([a-zA-Z]{2,}|xyz|top|site|click|online)\b"""
                .toRegex(RegexOption.IGNORE_CASE)

        return regex.findAll(text)
            .map { it.value.lowercase() }
            .toList()
    }

    private fun calculateRisk(url: String): RiskLevel {

        if (suspiciousHosts.any { url.contains(it) })
            return RiskLevel.HIGH

        val tld = url.substringAfterLast(".", "")

        if (suspiciousTlds.contains(tld))
            return RiskLevel.HIGH

        val score =
            suspiciousKeywords.count {

                url.contains(it)
            }

        return when {

            score >= 2 -> RiskLevel.HIGH

            score == 1 -> RiskLevel.MEDIUM

            else -> RiskLevel.LOW
        }
    }

    private fun handleThreat(url: String, risk: RiskLevel) {

        lastDetectedUrl = url

        lastAlertTime = System.currentTimeMillis()

        sendToFlutter(url, risk)

        val title =
            if (risk == RiskLevel.HIGH)
                "🚨 Scam Alert"
            else
                "⚠️ Suspicious Link"

        NotificationHelper.showNotification(
            this,
            title,
            "Risk: $risk | Link: $url"
        )
    }

    private fun shouldIgnore(url: String): Boolean {

        val now = System.currentTimeMillis()

        if (url == lastDetectedUrl &&
            now - lastAlertTime < ALERT_COOLDOWN
        ) return true

        if (url.startsWith("chrome://") ||
            url.length < 4
        ) return true

        return false
    }

    private fun initFlutter() {

        try {

            val engineId = "scam_kavatch_engine"

            var engine =
                FlutterEngineCache
                    .getInstance()
                    .get(engineId)

            if (engine == null) {

                engine = FlutterEngine(this)

                engine.dartExecutor.executeDartEntrypoint(
                    DartExecutor.DartEntrypoint.createDefault()
                )

                FlutterEngineCache
                    .getInstance()
                    .put(engineId, engine)
            }

            methodChannel =
                MethodChannel(
                    engine.dartExecutor.binaryMessenger,
                    CHANNEL
                )

        } catch (e: Exception) {

            Log.e(TAG, "Flutter Init Failed", e)
        }
    }

    private fun sendToFlutter(
        url: String,
        risk: RiskLevel
    ) {

        val args =
            hashMapOf(
                "url" to url,
                "risk" to risk.name
            )

        handler.post {

            methodChannel?.invokeMethod(
                "onUrlDetected",
                args
            )
        }
    }

    override fun onInterrupt() {

        Log.d(TAG, "Service Interrupted")
    }
}
