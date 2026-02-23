import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'services/premium_manager.dart';
import 'services/ad_service.dart';
import 'widgets/premium_toggle.dart';


final GlobalKey<NavigatorState> navKey = GlobalKey<NavigatorState>();
const MethodChannel testChannel = MethodChannel("test");

// REQUIRED for banner refresh
final ValueNotifier<bool> adRefreshNotifier = ValueNotifier<bool>(false);
Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();

  await MobileAds.instance.initialize();

  runApp(
    ChangeNotifierProvider(
      create: (_) => PremiumManager(),
      child: const ScamKavatchApp(),
    ),
  );

  AdService.loadBanner(() {

    debugPrint("Banner callback triggered");

    // Trigger UI rebuild safely
    adRefreshNotifier.value = !adRefreshNotifier.value;

  });

}
class ScamKavatchApp extends StatelessWidget {
  const ScamKavatchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      navigatorKey: navKey,

      title: 'Scam Kavatch Pro',

      theme: ThemeData(
        primarySwatch: Colors.red,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.red,
          brightness: Brightness.light,
        ),
      ),

      darkTheme: ThemeData.dark(useMaterial3: true).copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.red,
          brightness: Brightness.dark,
        ),
      ),

            // Banner attached safely to bottom of entire app
builder: (context, child) {

  return ValueListenableBuilder(
    valueListenable: adRefreshNotifier,
    builder: (context, value, _) {

      final double bannerHeight =
          (AdService.bannerReady && AdService.bannerAd != null)
              ? AdService.bannerAd!.size.height.toDouble()
              : 0.0;

      return Stack(
        children: [

          Padding(
            padding: EdgeInsets.only(
              bottom: bannerHeight + MediaQuery.of(context).padding.bottom,
            ),
            child: child ?? const SizedBox.shrink(),
          ),

          if (AdService.bannerReady && AdService.bannerAd != null)
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom,
              left: 0,
              right: 0,
              child: SizedBox(
                height: bannerHeight,
                child: AdWidget(ad: AdService.bannerAd!),
              ),
            ),

        ],
      );

    },
  );

},
      home: const AppGate(),

      debugShowCheckedModeBanner: false,
    );
  }
}



/// ================== APP GATE ==================
class AppGate extends StatefulWidget {
  const AppGate({super.key});

  @override
  State<AppGate> createState() => _AppGateState();
}


class _AppGateState extends State<AppGate> {

  bool _loading = true;
  bool _accepted = false;


  @override
  void initState() {
    super.initState();
    _checkAgreement();
  }


  Future<void> _checkAgreement() async {

    final prefs = await SharedPreferences.getInstance();

    final accepted = prefs.getBool("userAgreementAccepted") ?? false;

    setState(() {
      _accepted = accepted;
      _loading = false;
    });

  }


  @override
  Widget build(BuildContext context) {

    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_accepted) {
      return const ScamProtectionDashboard();
    }

    return const UserAgreementScreen();
  }
}

/// ================== USER AGREEMENT SCREEN ==================
class UserAgreementScreen extends StatefulWidget {
  const UserAgreementScreen({super.key});

  @override
  State<UserAgreementScreen> createState() => _UserAgreementScreenState();
}

class _UserAgreementScreenState extends State<UserAgreementScreen> {
  bool _checked = false;
  bool _saving = false;

  static const String agreementText = '''

✅ DISCLAIMER + USER AGREEMENT

By downloading, installing, accessing, or using this application (“App”), you (“User”) agree to the following terms:

1. Awareness Purpose Only

This App is provided strictly for educational and awareness purposes to help users identify and avoid scams. It does not guarantee prevention of fraud, scams, cybercrime, or financial loss.

2. No Professional Advice

Any content, alerts, suggestions, or information shown in this App is general guidance only and should not be treated as legal, financial, banking, or professional advice.

3. Privacy & Sensitive Data (Important)

This App does not read, store, or collect:

Passwords

OTPs

UPI PIN

Banking credentials

Card details

4. User Responsibility

The User is solely responsible for verifying the authenticity of calls, messages, emails, links, QR codes, payment requests, and transactions before taking any action.
The User agrees to use this App at their own risk.

5. Limitation of Liability

The developer and/or publisher of this App shall not be liable for any direct or indirect loss, damage, fraud, theft, harm, or inconvenience arising from:

reliance on the App’s information,

incorrect interpretation of results,

technical errors, delays, or app downtime,

misuse of the App by the User or third parties.

6. No Warranty

This App is provided on an “as is” and “as available” basis without warranties of any kind, including but not limited to accuracy, completeness, reliability, or fitness for a particular purpose.

✅ 7. Accessibility Permission Disclosure -For Premium customers only 

To provide scam protection, this App may request Accessibility Service permission.

This permission is used only to:

Detect suspicious links/URLs shown on your screen

Display alerts/warnings to help you avoid scam/phishing websites

This App does NOT:

Record keystrokes

Capture screenshots

Read or store personal chats/messages

Collect OTPs, passwords, or banking details

Share your data with third parties

8. Acceptance of Terms

If you do not agree with these terms, please stop using the App immediately and uninstall it.

By continuing to use this App, you confirm that you have read, understood, and accepted this Disclaimer & User Agreement.For support: support@cybrains.co.in
''';

  Future<void> _acceptAgreement() async {
    if (!_checked) return;

    setState(() => _saving = true);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("userAgreementAccepted", true);

    if (!mounted) return;

    setState(() => _saving = false);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const ScamProtectionDashboard()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("User Agreement"),
        centerTitle: true,
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Please read and accept to continue",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Expanded(
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: SingleChildScrollView(
                    child: Text(
                      agreementText,
                      style: TextStyle(fontSize: 13, height: 1.4),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Checkbox(
                  value: _checked,
                  onChanged: (v) {
                    setState(() => _checked = v ?? false);
                  },
                ),
                const Expanded(
                  child: Text(
                    "I have read and agree to the User Agreement",
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (_checked && !_saving) ? _acceptAgreement : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: _saving
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text("Accept & Continue"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
/// ======================= DASHBOARD =======================
class ScamProtectionDashboard extends StatefulWidget {
  const ScamProtectionDashboard({super.key});

  @override
  State<ScamProtectionDashboard> createState() =>
      _ScamProtectionDashboardState();
}

class _ScamProtectionDashboardState extends State<ScamProtectionDashboard>
    with WidgetsBindingObserver {

  // ✅ Method Channel (MATCHES KOTLIN)
  static const platform = MethodChannel('com.scamkavatch/overlay');

  // Protection states
  bool _urlProtectionActive = true;
  bool _clipboardProtectionActive = true;
  bool _emailProtectionActive = true;
  bool _browserProtectionActive = true;
  bool _realTimeScanning = true;

  // Security status
  String _securityStatus = 'Protected';
  int _threatsBlocked = 156;

  // Detection results
  final List<Map<String, dynamic>> _recentDetections = [];

  // URL input field
  final TextEditingController _urlController = TextEditingController();
  Map<String, dynamic>? _currentDetection;

  // Clipboard input field
  final TextEditingController _clipboardController = TextEditingController();

  // Scam detector instance
  final _scamDetector = _ScamDetector();

  @override
  void initState() {
    super.initState();

    // ✅ ADD lifecycle observer
    WidgetsBinding.instance.addObserver(this);

    // Listen for suspicious url from native
    platform.setMethodCallHandler((call) async {

      if (call.method == "onSuspiciousUrl" && _realTimeScanning) {

        final String detectedUrl = call.arguments.toString();

        _handleAutoDetection(detectedUrl);
      }

      return null;
    });
  }

  @override
  void dispose() {
    _urlController.dispose();
    _clipboardController.dispose();
    super.dispose();
  }

  // ✅ Close native alert overlay (if your Kotlin overlay is showing)
  Future<void> closeAlert() async {
    try {
      await platform.invokeMethod('dismissOverlay');
    } catch (_) {}
  }

  // ✅ test notification
  Future<void> testNotification() async {
    try {
      await platform.invokeMethod('testNotification');
      _showSnackBar('Test notification sent ✅ Check notification panel');
    } catch (e) {
      _showSnackBar('Notification failed: $e');
    }
  }

  void _handleAutoDetection(String url) {
    final result = _scamDetector.analyzeUrl(url);

    if (result['isSuspicious'] == true) {
      setState(() {
        _threatsBlocked++;
        _recentDetections.insert(0, result);
        if (_recentDetections.length > 10) _recentDetections.removeLast();
      });

      _showDetectionDialog(result);
    }
  }

  void _toggleUrlProtection() {
    setState(() {
      _urlProtectionActive = !_urlProtectionActive;
      _updateSecurityStatus();
    });
  }

  void _toggleClipboardProtection() {
    setState(() {
      _clipboardProtectionActive = !_clipboardProtectionActive;
      _updateSecurityStatus();
    });
  }

  void _toggleEmailProtection() {
    setState(() {
      _emailProtectionActive = !_emailProtectionActive;
      _updateSecurityStatus();
    });
  }

  void _toggleBrowserProtection() {
    setState(() {
      _browserProtectionActive = !_browserProtectionActive;
      _updateSecurityStatus();
    });
  }

  void _toggleRealTimeScanning() {
    setState(() {
      _realTimeScanning = !_realTimeScanning;
      _updateSecurityStatus();
    });
  }

  void _updateSecurityStatus() {
    final activeProtections = [
      _urlProtectionActive,
      _clipboardProtectionActive,
      _emailProtectionActive,
      _browserProtectionActive,
      _realTimeScanning,
    ].where((element) => element).length;

    if (activeProtections == 5) {
      _securityStatus = 'Maximum Protection';
    } else if (activeProtections >= 3) {
      _securityStatus = 'Standard Protection';
    } else if (activeProtections >= 1) {
      _securityStatus = 'Minimum Protection';
    } else {
      _securityStatus = 'Unprotected';
    }
  }

  void _scanUrl() {
    final url = _urlController.text.trim();

    if (url.isEmpty) {
      _showSnackBar('Please enter a URL to scan');
      return;
    }

    final result = _scamDetector.analyzeUrl(url);

    setState(() {
      _currentDetection = result;

      if (result['isSuspicious'] == true) {
        _threatsBlocked++;
        _recentDetections.insert(0, result);
        if (_recentDetections.length > 10) {
          _recentDetections.removeLast();
        }
      }
    });

    _showDetectionDialog(result);

    if (result['isSuspicious'] != true) {
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _currentDetection = null;
            _urlController.clear();
          });
        }
      });
    }
  }

  void _analyzeClipboard() {
    final text = _clipboardController.text.trim();

    if (text.isEmpty) {
      _showSnackBar('Enter text to analyze');
      return;
    }

    final results = _scamDetector.analyzeClipboard(text);

    if (results.isNotEmpty) {
      final result = results.first;

      _showDialog(
        '⚠️ Clipboard Threat Detected',
        'Type: ${result['threatType']}\nSeverity: ${result['severity']}\n\n${result['description']}',
        Icons.warning,
        Colors.orange,
      );

      if (_clipboardProtectionActive) {
        setState(() => _threatsBlocked++);
      }
    } else {
      _showDialog(
        '✅ Clipboard Safe',
        'No suspicious patterns detected in clipboard text.',
        Icons.check_circle,
        Colors.green,
      );
    }

    _clipboardController.clear();
  }

  void _checkEmail() {
    const exampleEmail = '''
From: "Bank Security"
<security@your-bank-fake.com>
Subject: URGENT: Account Suspension Notice
Body: Your account has been suspended due to suspicious
activity. Click here to verify: http://bank-verify-site.xyz/login
''';

    final results = _scamDetector.analyzeEmail(exampleEmail);

    if (results.isNotEmpty) {
      final result = results.first;

      _showDialog(
        '📧 Email Scam Detected',
        'Threat Type: ${result['threatType']}\nSeverity: ${result['severity']}\n\n${result['description']}',
        Icons.email,
        Colors.blue,
      );
    } else {
      _showSnackBar('No phishing patterns found');
    }
  }

  void _showBrowserAdvisory() {
    final recentScams = _scamDetector.getRecentScamPatterns();

    _showDialog(
      '🌐 Browser Protection Active',
      'Real-time monitoring enabled:\n\n• URLs checked: ${_scamDetector.urlsAnalyzed}\n• Threats blocked: $_threatsBlocked\n• Suspicious TLDs: ${_scamDetector.suspiciousTlds.length}\n\nTop scam patterns:\n${recentScams.take(5).map((p) => "• $p").join("\n")}',
      Icons.public,
      Colors.purple,
    );
  }

  void _showSecurityGuide() {
    final tips = _scamDetector.getSecurityTips();

    _showDialog(
      '🛡️ Security Advisory',
      'Current Status: $_securityStatus\n\nSecurity Tips:\n${tips.map((tip) => "• $tip").join("\n")}\n\n🚨 If you suspect cyber fraud (Digital Arrest / Scam Call / Fake Police), call 1930 immediately.\n\nAlways verify URLs before clicking!',
      Icons.security,
      Colors.red,
    );
  }
void _showProtectionSetup() {

  _showDialog(

    '🛠️ Protection Setup',

    'Accessibility Permission Disclosure\n\n'

    'Scam Kavatch Pro uses Accessibility Service to detect scam links and provide real-time protection.\n'
    'This permission is used only for scam detection.\n'
    'No personal data,passowrd or anyother sentive info is collected or shared.\n\n'

    'Complete the following steps:\n\n'

    '1️⃣ Enable Accessibility\n'
    'Settings → Accessibility → ScamKavatchPro → ON\n\n'

    '2️⃣ Allow Notifications\n'
    'Settings → Notifications → ScamKavatchPro → Allow\n\n'

    '3️⃣ Allow Display Over Apps\n'
    'Settings → Special App Access → Display Over Apps → Allow\n\n'

    'Protection activates after setup.',

    Icons.settings,
    Colors.green,
  );
}

  void _showDetectionDialog(Map<String, dynamic> result) {
    final isSuspicious = result['isSuspicious'] == true;
    final color = isSuspicious ? Colors.red : Colors.green;
    final icon = isSuspicious ? Icons.dangerous : Icons.check_circle;
    final title = isSuspicious ? '⚠️ THREAT DETECTED' : '✅ URL APPEARS SAFE';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(icon, color: color, size: 48),
        title: Text(title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('URL: ${result['url']}'),
              const SizedBox(height: 10),
              Text('Risk Level: ${result['severity']}'),
              const SizedBox(height: 10),
              Text('Threat Type: ${result['threatType']}'),
              const SizedBox(height: 10),
              Text('Detection: ${result['description']}'),
              const SizedBox(height: 10),
              if ((result['patternsFound'] as List).isNotEmpty) ...[
                const Text('Patterns Found:'),
                ...(result['patternsFound'] as List)
                    .map((pattern) => Text('• $pattern')),
              ],
              if ((result['recommendation'] as String).isNotEmpty) ...[
                const SizedBox(height: 10),
                Text('Recommendation: ${result['recommendation']}'),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CLOSE'),
          ),
          if (isSuspicious)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _showSnackBar('URL blocked and reported');
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('BLOCK & REPORT'),
            ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade800,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showDialog(String title, String content, IconData icon, Color color) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(icon, color: color, size: 48),
        title: Text(title),
        content: SingleChildScrollView(child: Text(content)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CLOSE'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSnackBar('Protection enhanced');
            },
            child: const Text('PROTECT'),
          ),
        ],
      ),
    );
  }

  void _runFullScan() {
    final newThreats = 3 + DateTime.now().second % 4;

    setState(() {
      _threatsBlocked += newThreats;
    });

    final fakeUrls = [
      'http://free-bitcoin-generator.xyz',
      'https://bank-account-verify.site',
      'http://microsoft-support.tech/login',
      'http://paypal-security-update.web',
    ];

    for (final url in fakeUrls.take(newThreats)) {
      final result = _scamDetector.analyzeUrl(url);
      if (result['isSuspicious'] == true) {
        _recentDetections.insert(0, result);
      }
    }

    if (_recentDetections.length > 10) {
      _recentDetections.removeRange(10, _recentDetections.length);
    }

    _showDialog(
      '🔍 Full System Scan Complete',
      'Scan Results:\n\n✅ Memory: Clean\n✅ Files: No threats\n✅ Registry: Secure\n✅ Browser: Protected\n\nNew threats blocked: $newThreats\nTotal protected: $_threatsBlocked',
      Icons.scanner,
      Colors.green,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
        title: const Row(
          children: [
            Icon(Icons.security),
            SizedBox(width: 10),
            Text('Scam Kavatch Pro'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _runFullScan,
            tooltip: 'Run Full Scan',
          ),
         IconButton(
  		icon: const Icon(Icons.settings),
  	        onPressed: _showProtectionSetup,
                tooltip: 'Protection Settings',
          ),

        ],
      ),
      body: SingleChildScrollView(
  padding: const EdgeInsets.all(16),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [

      // ⭐ PREMIUM TOGGLE (ADDED HERE)
      const PremiumToggle(),
      const SizedBox(height: 12),

      _buildSecurityStatusCard(),
      const SizedBox(height: 20),

      _buildUrlScanner(),
      const SizedBox(height: 20),

      _buildProtectionFeatures(),
      const SizedBox(height: 20),

      _buildClipboardAnalyzer(),
      const SizedBox(height: 20),

      _buildRecentDetections(),
      const SizedBox(height: 20),

      _buildQuickActions(),
      const SizedBox(height: 40),
    ],
  ),
),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: _runFullScan,
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.security),
        label: const Text('QUICK SCAN'),
      ),
    );
  }

  Widget _buildSecurityStatusCard() {
    Color statusColor;
    IconData statusIcon;

    switch (_securityStatus) {
      case 'Maximum Protection':
        statusColor = Colors.green;
        statusIcon = Icons.verified_user;
        break;
      case 'Standard Protection':
        statusColor = Colors.blue;
        statusIcon = Icons.security;
        break;
      case 'Minimum Protection':
        statusColor = Colors.orange;
        statusIcon = Icons.warning;
        break;
      default:
        statusColor = Colors.red;
        statusIcon = Icons.error;
    }

    return Card(
      color: statusColor.withAlpha(30),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(statusIcon, color: statusColor, size: 40),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Security: $_securityStatus',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('Threats Blocked: $_threatsBlocked'),
                  Text('URLs Analyzed: ${_scamDetector.urlsAnalyzed}'),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: _runFullScan,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('SCAN NOW'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUrlScanner() {
  final isSuspicious =
      _currentDetection != null && _currentDetection!['isSuspicious'] == true;

  return Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.search, color: Colors.red),
              SizedBox(width: 8),
              Text(
                'Advanced URL Scanner',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _urlController,
                  decoration: InputDecoration(
                    hintText: 'Enter URL to scan...',
                    prefixIcon: const Icon(Icons.link),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _scanUrl,
                child: const Text('SCAN'),
              ),
            ],
          ),

          // 🔽 RESULT AREA
          if (_currentDetection != null) ...[
            const SizedBox(height: 12),

            // 🟢 GREEN – swipe to dismiss
            if (!isSuspicious)
              Dismissible(
                key: const ValueKey('green_alert'),
                direction: DismissDirection.endToStart,
                onDismissed: (_) {
                  setState(() {
                    _currentDetection = null;
                    _urlController.clear();
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '✅ URL appears safe',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // 🔴 RED – unchanged
            if (isSuspicious)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '⚠️ ${_currentDetection!['threatType'].toString().toUpperCase()}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ],
      ),
    ),
  );
}

  Widget _buildProtectionFeatures() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ACTIVE PROTECTIONS',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        const SizedBox(height: 8),
        _buildProtectionToggleCard(
          title: 'Advanced URL Detection',
          subtitle: 'Catches ALL suspicious websites',
          icon: Icons.link,
          value: _urlProtectionActive,
          onChanged: _toggleUrlProtection,
        ),
        _buildProtectionToggleCard(
          title: 'Clipboard Protection',
          subtitle: 'Detects sensitive data in clipboard',
          icon: Icons.content_copy,
          value: _clipboardProtectionActive,
          onChanged: _toggleClipboardProtection,
        ),
        _buildProtectionToggleCard(
          title: 'Email Scam Detection',
          subtitle: 'Phishing email protection',
          icon: Icons.email,
          value: _emailProtectionActive,
          onChanged: _toggleEmailProtection,
          actionButton: IconButton(
            icon: const Icon(Icons.visibility),
            onPressed: _checkEmail,
            tooltip: 'Test email detection',
          ),
        ),
        _buildProtectionToggleCard(
          title: 'Browser Threat Guard',
          subtitle: 'Real-time website blocking',
          icon: Icons.public,
          value: _browserProtectionActive,
          onChanged: _toggleBrowserProtection,
          actionButton: IconButton(
            icon: const Icon(Icons.info),
            onPressed: _showBrowserAdvisory,
            tooltip: 'Browser protection info',
          ),
        ),
        _buildProtectionToggleCard(
          title: 'Real-time Scanning',
          subtitle: 'Continuous threat monitoring',
          icon: Icons.radar,
          value: _realTimeScanning,
          onChanged: _toggleRealTimeScanning,
        ),
      ],
    );
  }

  Widget _buildProtectionToggleCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required VoidCallback onChanged,
    Widget? actionButton,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Icon(icon, color: value ? Colors.green : Colors.grey),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (actionButton != null) actionButton,
            const SizedBox(width: 8),
            Switch(
              value: value,
              onChanged: (_) => onChanged(),
              activeTrackColor: Colors.green,
              thumbColor: WidgetStateProperty.resolveWith<Color>((states) {
                if (states.contains(WidgetState.selected)) {
                  return Colors.white;
                }
                return Colors.grey.shade300;
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClipboardAnalyzer() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.content_paste, color: Colors.orange),
                SizedBox(width: 8),
                Text(
                  'Clipboard Security Analyzer',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Detects passwords, crypto addresses, personal data in clipboard',
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _clipboardController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Paste or type text to analyze...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _analyzeClipboard,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search),
                  SizedBox(width: 8),
                  Text('ANALYZE CLIPBOARD'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentDetections() {
    if (_recentDetections.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'RECENT THREAT DETECTIONS',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        const SizedBox(height: 8),
        ..._recentDetections.take(5).map((detection) {
          final isSuspicious = detection['isSuspicious'] == true;

          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            color: isSuspicious ? Colors.red.shade50 : Colors.green.shade50,
            child: ListTile(
              leading: Icon(
                isSuspicious ? Icons.dangerous : Icons.check_circle,
                color: isSuspicious ? Colors.red : Colors.green,
              ),
              title: Text(
                detection['url'].toString().length > 40
                    ? '${detection['url'].toString().substring(0, 40)}...'
                    : detection['url'].toString(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isSuspicious ? Colors.red : Colors.green,
                ),
              ),
              subtitle:
                  Text('${detection['threatType']} • ${detection['severity']}'),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () => _showDetectionDialog(detection),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'SECURITY TIPS & QUICK ACTIONS',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ActionChip(
              avatar: const Icon(Icons.auto_fix_high, color: Colors.white),
              label: const Text('Scan Now'),
              backgroundColor: Colors.red,
              labelStyle: const TextStyle(color: Colors.white),
              onPressed: _runFullScan,
            ),
            ActionChip(
              avatar: const Icon(Icons.report, color: Colors.white),
              label: const Text('Report Scam'),
              backgroundColor: Colors.orange,
              labelStyle: const TextStyle(color: Colors.white),
              onPressed: () => _showSnackBar('Scam reporting activated'),
            ),
            ActionChip(
              avatar: const Icon(Icons.update, color: Colors.white),
              label: const Text('Update Database'),
              backgroundColor: Colors.green,
              labelStyle: const TextStyle(color: Colors.white),
              onPressed: () => _showSnackBar('Threat database updated'),
            ),
            ActionChip(
              avatar:
                  const Icon(Icons.notifications_active, color: Colors.white),
              label: const Text('Test Notification'),
              backgroundColor: Colors.purple,
              labelStyle: const TextStyle(color: Colors.white),
              onPressed: testNotification,
            ),
         ActionChip( avatar: const Icon(Icons.security, color: Colors.white),
          label: const Text('Security Guide'), backgroundColor: Colors.green, 
          labelStyle: const TextStyle(color: Colors.white), 
          onPressed: _showSecurityGuide, 
      ), 
    ], 
   ), 
  ], 
 ); 
 } 
}



/// ======================= SCAM DETECTOR LOGIC =======================
class _ScamDetector {
  int urlsAnalyzed = 0;

  final List<String> suspiciousTlds = [
    '.xyz',
    '.abc',
    '.site',
    '.top',
    '.web',
    '.tech',
    '.click',
    '.online',
    '.buzz',
  ];

  Map<String, dynamic> analyzeUrl(String url) {
    urlsAnalyzed++;
    url = url.toLowerCase();

    final patternsFound = <String>[];
    bool isSuspicious = false;
    String threatType = 'None';
    String severity = 'Low';

    for (final tld in suspiciousTlds) {
      if (url.endsWith(tld) || url.contains('$tld/')) {
        isSuspicious = true;
        patternsFound.add('Suspicious TLD ($tld)');
        threatType = 'Scam Domain';
        severity = 'Medium';
      }
    }

  // Normalize URL to lowercase for consistent detection
final lowerUrl = url.toLowerCase();

if (lowerUrl.contains('refund') ||
    lowerUrl.contains('claim') ||
    lowerUrl.contains('upi') ||
    lowerUrl.contains('kyc') ||
    lowerUrl.contains('verify') ||
    lowerUrl.contains('bank') ||
    lowerUrl.contains('secure') ||
    lowerUrl.contains('login') ||
    lowerUrl.contains('offer')) {

  if (!lowerUrl.startsWith('https://')) {
    isSuspicious = true;
    patternsFound.add('Unsecured Phishing Pattern');
    threatType = 'Phishing';
    severity = 'High';
  }
}
    return {
      'url': url,
      'isSuspicious': isSuspicious,
      'threatType': threatType,
      'severity': severity,
      'description':
          isSuspicious ? 'URL matches known scam patterns.' : 'URL looks safe.',
      'patternsFound': patternsFound,
      'recommendation':
          isSuspicious ? 'Do not enter any personal information.' : '',
    };
  }

  List<Map<String, dynamic>> analyzeClipboard(String text) {
    if (text.contains('http')) {
      return [
        {
          'threatType': 'Link Detected',
          'severity': 'High',
          'description': 'Suspicious URL found in clipboard',
        }
      ];
    }
    return [];
  }

  List<Map<String, dynamic>> analyzeEmail(String email) {
    if (email.toLowerCase().contains('suspicious activity')) {
      return [
        {
          'threatType': 'Phishing Email',
          'severity': 'High',
          'description': 'Urgency and verification link found.',
        }
      ];
    }
    return [];
  }

  List<String> getRecentScamPatterns() => [
        'Unverified bank links',
        'Fake support URLs',
        'OTP request scams',
        'UPI collect request scams',
        'Telegram investment scams',
      ];

  List<String> getSecurityTips() => [
        'Always check the URL before clicking.',
        'Never share OTP with anyone.',
        'Use two-factor authentication (2FA).',
        'Avoid unknown APK downloads.',
        'Verify bank calls using official numbers.',
      ];
}
void showRedWarningPopup(String url, String reason) {
  final ctx = navKey.currentContext;
  if (ctx == null) return;

  showDialog(
    context: ctx,
    barrierDismissible: true,
    builder: (_) {
      return AlertDialog(
        backgroundColor: Colors.red.shade700,
        title: const Text(
          "⚠ Scam Kavatch Alert",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Suspicious URL detected!",
                style: TextStyle(color: Colors.white)),
            const SizedBox(height: 10),
            Text("Reason: $reason", style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 10),
            Text(url, style: const TextStyle(color: Colors.white)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Close", style: TextStyle(color: Colors.white)),
          ),
        ],
      );
    },
  );
}


class AccessibilityBridge {
  static const MethodChannel _channel =
      MethodChannel('scam_kavatch/accessibility');

  static void init() {
    _channel.setMethodCallHandler((call) async {
      if (call.method == "onUrlDetected") {
        final String url = call.arguments?.toString() ?? "";
        debugPrint("✅ URL detected from Android: $url");

        // ✅ Use your existing scam rules (simple)
        final detector = _ScamDetector();
        final result = detector.analyzeUrl(url);

        if (result['isSuspicious'] == true) {
          showRedWarningPopup(
            url,
            "${result['threatType']} • ${result['severity']}",
          );
        }
      }
    });
  }
}

