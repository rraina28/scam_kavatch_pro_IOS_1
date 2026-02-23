import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/premium_manager.dart';

class PremiumToggle extends StatelessWidget {

  const PremiumToggle({super.key});

  @override
  Widget build(BuildContext context) {

    final premium = context.watch<PremiumManager>();

    return Card(

      elevation: 2,

      child: ListTile(

        leading: const Icon(
          Icons.workspace_premium,
          color: Colors.amber,
          size: 28,
        ),

        title: const Text(
          "Premium Protection",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),

        subtitle: premium.isPremium

            ? const Row(
                children: [

                  Icon(Icons.verified,
                      color: Colors.green, size: 16),

                  SizedBox(width: 6),

                  Text("Active  •  "),

                  Icon(Icons.settings, size: 16),

                  SizedBox(width: 4),

                  Expanded(
                    child: Text(
                      "Open Protection Setup in Settings",
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              )

            : const Text(
                "Upgrade for ₹39/month or ₹249/year",
                style: TextStyle(fontSize: 13),
              ),

        trailing: premium.isPremium

            ? const Icon(
                Icons.verified,
                color: Colors.green,
                size: 26,
              )

            : _buildUpgradeButton(context, premium),
      ),
    );
  }

  Widget _buildUpgradeButton(
      BuildContext context,
      PremiumManager premium) {

    if (premium.status == PremiumStatus.purchasing) {

      return const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2,
        ),
      );
    }

    return PopupMenuButton<String>(

      onSelected: (planId) async {

        final confirmed =
            await _showBenefitsDialog(context, planId);

        if (confirmed == true && context.mounted) {

          premium.buyPremium(planId);

        }
      },

      itemBuilder: (context) => const [

        PopupMenuItem(
          value: PremiumManager.monthlyId,
          child: Text("Monthly Plan – ₹39/month"),
        ),

        PopupMenuItem(
          value: PremiumManager.yearlyId,
          child: Text("Yearly Plan – ₹249/year"),
        ),

      ],

      child: ElevatedButton(

        onPressed: null,

        style: ElevatedButton.styleFrom(
          disabledBackgroundColor:
              Theme.of(context).primaryColor,
          disabledForegroundColor: Colors.white,
        ),

        child: const Text("Upgrade"),

      ),
    );
  }

  Future<bool?> _showBenefitsDialog(
      BuildContext context,
      String planId) {

    final planName =
        planId == PremiumManager.monthlyId
            ? "₹39/month"
            : "₹249/year";

    return showDialog<bool>(

      context: context,

      barrierDismissible: false,

      builder: (context) {

        return AlertDialog(

          title: Text(
            "Upgrade to Premium ($planName)",
          ),

          content: const Column(

            mainAxisSize: MainAxisSize.min,

            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [

              Text(
                "Premium Benefits:",
                style: TextStyle(
                    fontWeight: FontWeight.bold),
              ),

              SizedBox(height: 16),

              Row(
                children: [
                  Icon(Icons.flash_on,
                      color: Colors.amber),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                        "AI-powered scam detection"),
                  ),
                ],
              ),

              SizedBox(height: 8),

              Row(
                children: [
                  Icon(Icons.security,
                      color: Colors.green),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                        "Real-time protection"),
                  ),
                ],
              ),

              SizedBox(height: 8),

              Row(
                children: [
                  Icon(Icons.notifications_active,
                      color: Colors.blue),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                        "Automatic scam alerts"),
                  ),
                ],
              ),

              SizedBox(height: 8),

              Row(
                children: [
                  Icon(Icons.block,
                      color: Colors.red),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text("No Ads"),
                  ),
                ],
              ),

            ],
          ),

          actions: [

            TextButton(
              onPressed: () =>
                  Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),

            ElevatedButton(
              onPressed: () =>
                  Navigator.pop(context, true),
              child: const Text("Continue"),
            ),

          ],
        );
      },
    );
  }
}