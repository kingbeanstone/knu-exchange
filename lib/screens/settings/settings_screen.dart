import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import '../../providers/auth_provider.dart';
import 'login_screen.dart';
import 'profile_edit_screen.dart';
import 'privacy_policy_screen.dart';
import 'contact_screen.dart';


class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    const knuRed = Color(0xFFDD1829);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: knuRed,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 10),
          authProvider.isAuthenticated
              ? _buildProfileTile(context, authProvider)
              : _buildLoginTile(context),
          const Divider(),

          // 일반 설정 항목들 (예시)
          _buildMenuTile(Icons.language, 'Language', 'English'),
          _buildMenuTile(Icons.notifications_outlined, 'Notifications', 'On'),

          const Divider(),
          // 약관/문의
          _buildMenuTile(
            Icons.privacy_tip_outlined,
            'Privacy Policy',
            '',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen()),
            ),
          ),
          _buildMenuTile(
            Icons.mail_outline,
            'Contact Us',
            '',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ContactScreen()),
            ),
          ),

          // 로그인 상태일 때만 회원 탈퇴 버튼 표시
          if (authProvider.isAuthenticated)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: TextButton(
                onPressed: () => _showDeleteAccountDialog(context, authProvider),
                child: const Text(
                  'Delete Account',
                  style: TextStyle(color: Colors.red, decoration: TextDecoration.underline),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProfileTile(BuildContext context, AuthProvider auth) {
    return Container(
      color: Colors.white,
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Color(0xFFDD1829),
          child: Icon(Icons.person, color: Colors.white),
        ),
        title: Text(auth.user?.displayName ?? auth.user?.email?.split('@')[0] ?? 'User'),
        subtitle: Text(auth.user?.email ?? ''),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
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
      ),
    );
  }

  Widget _buildLoginTile(BuildContext context) {
    return Container(
      color: Colors.white,
      child: ListTile(
        leading: const Icon(Icons.login, color: Color(0xFFDD1829)),
        title: const Text('Login / Sign Up'),
        subtitle: const Text('Log in to save your favorites'),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen())),
      ),
    );
  }

  Widget _buildMenuTile(
      IconData icon,
      String title,
      String trailing, {
        VoidCallback? onTap,
      }) {
    final hasTrailingText = trailing.trim().isNotEmpty;

    return Container(
      color: Colors.white,
      child: ListTile(
        leading: Icon(icon, color: Colors.grey),
        title: Text(title),

        // trailing 텍스트가 있으면 텍스트(+ 필요시 화살표),
        // trailing 텍스트가 없으면 이동 가능할 때만 화살표 표시
        trailing: hasTrailingText
            ? Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(trailing, style: const TextStyle(color: Colors.grey)),
            if (onTap != null) ...[
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ],
        )
            : (onTap != null
            ? const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey)
            : null),

        onTap: onTap, // ✅ 여기로 전달
      ),
    );
  }


  // 계정 삭제 확인 다이얼로그
  void _showDeleteAccountDialog(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account?\nAll your profile information will be permanently removed. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await auth.deleteAccount();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Account has been deleted.')),
                  );
                }
              } on FirebaseAuthException catch (e) {
                if (e.code == 'requires-recent-login') {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please log in again to delete your account.')),
                    );
                  }
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: ${e.message}')),
                    );
                  }
                }
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}