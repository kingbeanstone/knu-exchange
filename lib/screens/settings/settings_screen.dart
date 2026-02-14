import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'login_screen.dart'; // 로그인 화면으로 이동하기 위해 필요
import 'profile_edit_screen.dart'; // 수정 화면 임포트

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

  // 로그인 상태일 때 표시될 프로필 타일
  Widget _buildProfileTile(BuildContext context, AuthProvider auth) {
    return ListTile(
      leading: const CircleAvatar(
        backgroundColor: Color(0xFFDD1829),
        child: Icon(Icons.person, color: Colors.white),
      ),
      // 닉네임 표시 (displayName이 없으면 이메일 앞부분 표시)
      title: Text(auth.user?.displayName ?? auth.user?.email?.split('@')[0] ?? 'User'),
      subtitle: Text(auth.user?.email ?? ''),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 프로필 수정 버튼 추가
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.grey),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfileEditScreen()),
            ),
          ),
          const SizedBox(width: 8),
          OutlinedButton(
            onPressed: () => auth.logout(),
            style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFFDD1829))),
            child: const Text('Logout', style: TextStyle(color: Color(0xFFDD1829))),
          ),
        ],
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