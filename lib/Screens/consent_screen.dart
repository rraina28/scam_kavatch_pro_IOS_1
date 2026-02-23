import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'user_agreement_screen.dart';

class ConsentScreen extends StatefulWidget {
  const ConsentScreen({super.key});

  static const String routeName = '/consent';

  @override
  State<ConsentScreen> createState() => _ConsentScreenState();
}

class _ConsentScreenState extends State<ConsentScreen> {
  bool _agreed = false;
  bool _loading = false;

  Future<void> _acceptAndContinue() async {
    if (!_agreed) return;

    setState(() => _loading = true);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('agreementAccepted', true);

    // Optional: store version & time for compliance tracking
    await prefs.setString('agreementAcceptedVersion', '1.0.0');
    await prefs.setString('agreementAcceptedOn', DateTime.now().toIso8601String());

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/home');
  }

  void _openAgreement() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const UserAgreementScreen(),
      ),
    );
  }

  void _exitDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Exit"),
        content: const Text(
          "You must accept the User Agreement to continue using Scam Kavatch Pro.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Consent Required'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Before you continue',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            const Text(
              'Scam Kavatch Pro is a scam awareness & safety tool. '
              'It may not detect every scam. Always verify information before making payments.',
              style: TextStyle(fontSize: 14, height: 1.4),
            ),

            const SizedBox(height: 12),

            InkWell(
              onTap: _openAgreement,
              child: const Text(
                'View User Agreement / Disclaimer',
                style: TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Checkbox(
                  value: _agreed,
                  onChanged: (val) {
                    setState(() {
                      _agreed = val ?? false;
                    });
                  },
                ),
                const Expanded(
                  child: Text(
                    'I agree to the User Agreement / Disclaimer',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _agreed && !_loading ? _acceptAndContinue : null,
                child: _loading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Accept & Continue'),
              ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _exitDialog,
                child: const Text('Exit'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
