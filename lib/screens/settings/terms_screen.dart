import 'package:flutter/material.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Terms of Service"),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Text(
            '''
KNU Exchange Terms of Service

Users may not post:
• Hate speech
• Harassment
• Sexual content
• Illegal content

KNU Exchange has zero tolerance for objectionable content or abusive users.

Team M reserves the right to remove any content that violates these rules.

Users who repeatedly violate these rules may be banned.
''',
          ),
        ),
      ),
    );
  }
}