

import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Terms of Service"),
        backgroundColor: AppColors.knuRed,
      ),
      body: const SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Text(
            '''
KNU Exchange – Terms of Service

Last updated: 2026

1. Acceptance of Terms
By using the KNU Exchange application, you agree to follow these terms and conditions.

2. User Accounts
Users are responsible for maintaining the security of their accounts and for all activity under their account.

3. Community Guidelines
Users must not post illegal, abusive, hateful, or harmful content. The service reserves the right to remove any content that violates community rules.

4. Content Responsibility
Users are responsible for the content they post in the community section.

5. Moderation
KNU Exchange may remove posts, suspend accounts, or restrict access if users violate the community guidelines.

6. Service Changes
The service may update or modify these terms when necessary.

7. Contact
For questions regarding these terms, please contact:
TeamMillionM@gmail.com
            ''',
            style: TextStyle(
              fontSize: 14,
              height: 1.6,
            ),
          ),
        ),
      ),
    );
  }
}