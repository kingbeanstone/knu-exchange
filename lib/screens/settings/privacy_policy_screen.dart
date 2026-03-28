import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  static const String _privacyText = '''
# **Privacy Policy**

**KNU Exchange Privacy Policy**

Last updated: March 7, 2026

KNU Exchange (“the App”) respects your privacy and is committed to protecting your personal information. This Privacy Policy explains what information we collect, how we use it, and how it is protected.

---

## **1. Information We Collect**

Users can browse most features of the App without creating an account.
An account is only required for community features such as posting or commenting.

We may collect the following types of information:

### **a) Account Information**

Some features of the App (such as posting or commenting) require creating an account using Firebase Authentication. When you create an account, we may collect:

- Email address
- Unique user identifier (UID)

### **b) User-Generated Content**

When using the App, we may collect:

- Posts
- Comments
- Other text content voluntarily submitted by users


### **c) Technical Information**

We may automatically collect:

- Device type
- Operating system version
- App version
- Basic usage logs

### **d) Location Information**

The App may request access to your device’s location to display your current position on the campus map.

Location data is used only within the App to provide map functionality and is not stored or shared with third parties.

---

## **2. How We Use Your Information**

We use collected information to:

- Provide authentication and account management
- Enable posting and commenting features
- Maintain and improve the App
- Ensure security and prevent misuse

We do not sell or rent your personal information to third parties.

---

## **3. Data Storage and Security**

- All user data is stored securely using Google Firebase services.
- We implement reasonable security measures to protect your information.
- Data is retained only as long as necessary to provide services.

---

## **4. Third-Party Services**

The App uses the following third-party services:

- **Google Firebase services (Authentication and Firestore)**

These services may process data in accordance with their own privacy policies.

---

## **5. User Rights**

You may request to:

- Access your personal data
- Correct inaccurate information
- Delete your account and associated data

To make such requests, please contact us using the information below.

---

## **6. Children’s Privacy**

The App is not intended for children under 13 years of age. We do not knowingly collect personal information from children under 13.

---

## **7. Changes to This Policy**

We may update this Privacy Policy from time to time. Updates will be posted at this URL.

---

## **8. Contact Information**

If you have questions regarding this Privacy Policy, please contact:

Email: [TeamMillionM@gmail.com](mailto:TeamMillionM@gmail.com)
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
