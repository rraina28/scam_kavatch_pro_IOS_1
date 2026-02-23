import 'package:flutter/material.dart';

class UserAgreementScreen extends StatelessWidget {
  const UserAgreementScreen({super.key});

  static const String routeName = '/user-agreement';

  // ✅ Full Disclaimer + User Agreement (FINAL)
 static const String agreementText = '''
Disclaimer & User Agreement

By downloading, installing, accessing, or using this application (“App”), you (“User”) agree to the following terms:

1. Awareness Purpose Only
This App is provided strictly for educational and awareness purposes to help users identify and avoid scams. It does not guarantee prevention of fraud, scams, cybercrime, or financial loss.

2. No Professional Advice
Any content, alerts, suggestions, or information shown in this App is general guidance only and should not be treated as legal, financial, banking, or professional advice.

3. Privacy & Sensitive Data (Important)
This App does not read, store, or collect:
• Passwords
• OTPs
• UPI PIN
• Banking credentials
• Card details
4. User Responsibility
The User is solely responsible for verifying the authenticity of calls, messages, emails, links, QR codes, payment requests, and transactions before taking any action.
The User agrees to use this App at their own risk.
5. Limitation of Liability
The developer and/or publisher of this App shall not be liable for any direct or indirect loss, damage, fraud, theft, harm, or inconvenience arising from:
• reliance on the App’s information,
• incorrect interpretation of results,
• technical errors, delays, or app downtime,
• misuse of the App by the User or third parties.
6. No Warranty
This App is provided on an “as is” and “as available” basis without warranties of any kind, including but not limited to accuracy, completeness, reliability, or fitness for a particular purpose.
7. Acceptance of Terms
If you do not agree with these terms, please stop using the App immediately and uninstall it.
✅ By continuing to use this App, you confirm that you have read, understood, and accepted this Disclaimer & User Agreement.
For support, contact: support@cybrains.co.in
''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Agreement / Disclaimer'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Scam Kavatch Pro',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
            child: Container(
    width: double.infinity,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey),
      borderRadius: BorderRadius.circular(12),
    ),
    child: const SingleChildScrollView(
      child: Text(
        agreementText,
        style: TextStyle(fontSize: 14, height: 1.4),
      ),
    ),
  ),
),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
