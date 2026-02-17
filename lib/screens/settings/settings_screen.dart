import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'login_screen.dart'; // 로그인 화면으로 이동하기 위해 필요
import 'privacy_policy_screen.dart';
import 'contact_screen.dart';


class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // AuthProvider의 상태를 지켜봅니다.
    final authProvider = Provider.of<AuthProvider>(context);
    const knuRed = Color(0xFFDD1829);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: knuRed,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 10),

          // --- 로그인/프로필 섹션 ---
          authProvider.isAuthenticated
              ? _buildProfileTile(context, authProvider)
              : _buildLoginTile(context),

          const Divider(),

          // --- 기존 설정 항목들 ---
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
              activeColor: knuRed,
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
            leading: const Icon(Icons.privacy_tip),
            title: const Text('Privacy Policy'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PrivacyPolicyScreen(),
                ),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.contact_support),
            title: const Text('Contact Us'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ContactScreen(),
                ),
              );
            },
          ),

        ],
      ),
    );
  }

  // 로그인 상태일 때 표시될 프로필 타일
  Widget _buildProfileTile(BuildContext context, AuthProvider auth) {
    return ListTile(
      leading: const CircleAvatar(
        backgroundColor: Color(0xFFDD1829),
        child: Icon(Icons.person, color: Colors.white),
      ),
      title: Text(auth.user?.email ?? 'User'),
      subtitle: const Text('Logged in via Email'),
      trailing: OutlinedButton(
        onPressed: () => auth.logout(),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFFDD1829)),
        ),
        child: const Text('Logout', style: TextStyle(color: Color(0xFFDD1829))),
      ),
    );
  }

  // 로그아웃 상태일 때 표시될 로그인 유도 타일
  Widget _buildLoginTile(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.login, color: Color(0xFFDD1829)),
      title: const Text('Login / Sign Up'),
      subtitle: const Text('Log in to save your favorites'),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        // 로그인 화면으로 이동
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      },
    );
  }
}