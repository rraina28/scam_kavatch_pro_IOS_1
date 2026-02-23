import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/premium_manager.dart';

class UpgradeScreen extends StatefulWidget {
  const UpgradeScreen({super.key});

  @override
  State<UpgradeScreen> createState() => _UpgradeScreenState();
}

class _UpgradeScreenState extends State<UpgradeScreen> {

  bool _popupShown = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handlePremiumSuccess();
    });
  }

  Future<void> _handlePremiumSuccess() async {

    if (!mounted) return;

    final premium = context.read<PremiumManager>();

    if (premium.showPremiumSuccess && !_popupShown) {

      _popupShown = true;

      final openSettings = await _showPremiumActivatedDialog();

      if (!mounted) return;

      premium.clearPremiumSuccessFlag();

      if (openSettings) {

        Navigator.pushNamed(context, "/settings");

      } else {

        Navigator.pop(context);

      }
    }
  }

  @override
  Widget build(BuildContext context) {

    final premium = context.watch<PremiumManager>();

    final isLoading =
        premium.status == PremiumStatus.loading ||
        premium.status == PremiumStatus.purchasing ||
        premium.status == PremiumStatus.restoring;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Upgrade to Premium"),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [

              const SizedBox(height: 40),

              const Icon(
                Icons.workspace_premium,
                size: 90,
                color: Colors.amber,
              ),

              const SizedBox(height: 20),

              const Text(
                "Scam Kavatch Pro Premium",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              const Text(
                "Activate full scam protection and real-time alerts.",
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 30),

              // BENEFITS BLOCK (fixed)
              const Column(
                children: [

                  _BenefitItem(
                    icon: Icons.block,
                    title: "No Ads",
                    subtitle: "Enjoy completely ad-free protection",
                  ),

                  _BenefitItem(
                    icon: Icons.notifications_active,
                    title: "Auto Scam Alerts",
                    subtitle: "Instant phishing and fraud detection",
                  ),

                  _BenefitItem(
                    icon: Icons.link,
                    title: "Unlimited Link Scanning",
                    subtitle: "Scan links instantly for safety",
                  ),

                  _BenefitItem(
                    icon: Icons.security,
                    title: "Real-time Protection",
                    subtitle: "Continuous background scam monitoring",
                  ),

                ],
              ),

              const SizedBox(height: 30),

              if (isLoading)
                const CircularProgressIndicator(),

              if (!isLoading)
                Column(
                  children: [

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          premium.buyPremium(PremiumManager.monthlyId);
                        },
                        child: const Text("Buy Monthly"),
                      ),
                    ),

                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          premium.buyPremium(PremiumManager.yearlyId);
                        },
                        child: const Text("Buy Yearly"),
                      ),
                    ),

                    const SizedBox(height: 16),

                    TextButton(
                      onPressed: () {
                        premium.restore();
                      },
                      child: const Text("Restore Purchase"),
                    ),

                  ],
                ),

              if (premium.status == PremiumStatus.error &&
                  premium.lastError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Text(
                    premium.lastError!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),

            ],
          ),
        ),
      ),
    );
  }

  // FIXED dialog returns bool
  Future<bool> _showPremiumActivatedDialog() async {

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {

        return AlertDialog(

          title: const Text("Premium Activated ✅"),

          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Text(
                "Your Scam Kavatch protection is now ready.",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              SizedBox(height: 16),

              Text("To activate protection, please enable:"),

              SizedBox(height: 12),

              Text(
                "Accessibility Permission",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              Text(
                "Settings → Accessibility → Installed Apps → Scam Kavatch Pro → Enable",
              ),

              SizedBox(height: 12),

              Text(
                "Notification Access",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              Text(
                "Settings → Apps → Special App Access → Notification Access → Enable Scam Kavatch Pro",
              ),

            ],
          ),

          actions: [

            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text("Later"),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text("Open Protection Settings"),
            ),

          ],
        );
      },
    );

    return result ?? false;
  }
}


// Benefit Item Widget
class _BenefitItem extends StatelessWidget {

  final IconData icon;
  final String title;
  final String subtitle;

  const _BenefitItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {

    return ListTile(
      leading: Icon(icon, color: Colors.green),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(subtitle),
    );
  }
}