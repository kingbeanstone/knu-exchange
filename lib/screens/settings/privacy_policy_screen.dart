import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Text(
            '''
KNU Exchange Privacy Policy

We respect your privacy.

1. We do not sell your personal data.
2. We only collect necessary information for app functionality.
3. Authentication is handled securely via Firebase.

If you have questions, please contact us.

© 2026 KNU Exchange
            ''',
            style: TextStyle(fontSize: 14),
          ),
        ),
      ),
    );
  }
}
