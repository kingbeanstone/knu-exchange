import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  static const String _privacyText = '''
**KNU EXCHANGE Privacy Policy**

Last updated: February 2026

KNU EXCHANGE (“the App”) is operated by M. We respect your privacy and are committed to protecting your personal information. This Privacy Policy explains what information we collect, how we use it, and how it is protected.

---

## **1. Information We Collect**

When you use KNU EXCHANGE, we may collect the following information:

### **a) Account Information**

When you create an account using email and password, we collect:

- Email address
- Unique user identifier (UID)

### **b) User-Generated Content**

When using the App, we collect:

- Posts
- Comments
- Other content voluntarily submitted by users

### **c) Technical Information**

We may automatically collect limited technical data necessary for the operation of the App, such as:

- Device type
- Operating system version
- App version

---

## **2. How We Use Your Information**

We use collected information to:

- Provide account authentication and login functionality
- Enable community features such as posting and commenting
- Maintain and improve the App
- Ensure security and prevent misuse

We do not sell, rent, or trade your personal information to third parties.

---

## **3. Data Storage and Security**

All user data is stored using Google Firebase services.

Data may be processed on servers located outside your country.

We take reasonable measures to protect your information from unauthorized access, loss, misuse, or alteration.

---

## **4. Account Deletion**

Users may delete their account at any time through the App.

When an account is deleted:

- The Firebase authentication account is permanently removed.
- Associated user data stored in Firestore is deleted.

---

## **5. Children’s Privacy**

The App is intended for users aged 13 and older.

We do not knowingly collect personal information from children under 13.

If you believe that a child under 13 has provided personal information, please contact us.

---

## **6. Third-Party Services**

The App uses Google Firebase for authentication and data storage.

These services may process data in accordance with their own privacy policies.

---

## **7. Changes to This Policy**

We may update this Privacy Policy from time to time. Updates will be posted at this URL with a revised “Last updated” date.

---

## **8. Contact Us**

If you have any questions about this Privacy Policy, please contact:

Team M

Email: TeamMillionM@gmail.com
''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Markdown(
          data: _privacyText,
        ),
      ),
    );
  }
}
