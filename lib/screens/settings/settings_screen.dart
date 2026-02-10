import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: const Color(0xFFDD1829),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 10),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Language'),
            subtitle: const Text('English / Korean'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // 언어 변경 기능
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notifications'),
            trailing: Switch(
              value: true,
              onChanged: (val) {
                // 알림 끄기/켜기
              },
              activeColor: const Color(0xFFDD1829),
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('App Version'),
            trailing: const Text('1.0.0', style: TextStyle(color: Colors.grey)),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.contact_support),
            title: const Text('Contact Us'),
            onTap: () {
              // 문의하기 (이메일 등)
            },
          ),
        ],
      ),
    );
  }
}