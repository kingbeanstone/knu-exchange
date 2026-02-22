import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'login_screen.dart';
import 'profile_edit_screen.dart';
import 'privacy_policy_screen.dart';
import 'contact_screen.dart';

import '../admin/admin_dashboard_screen.dart';
import '../../utils/app_colors.dart';
import '../../widgets/settings/settings_widgets.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.knuRed,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        children: [
          // 1. 프로필 섹션
          const SettingsSectionHeader(title: 'Profile'),
          SettingsGroupCard(
            child: authProvider.isAuthenticated
                ? SettingsProfileContent(auth: authProvider)
                : const SettingsLoginPrompt(),
          ),

          const SizedBox(height: 24),

          // 2. 관리자 섹션
          if (authProvider.isAdmin) ...[
            const SettingsSectionHeader(title: 'Management'),
            SettingsGroupCard(
              child: SettingsMenuTile(
                icon: Icons.admin_panel_settings_rounded,
                iconColor: Colors.blueAccent,
                title: 'Admin Dashboard',
                trailing: 'Manage',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],

          // 3. 일반 설정 섹션
          const SettingsSectionHeader(title: 'Preferences'),
          SettingsGroupCard(
            child: Column(
              children: [
                SettingsMenuTile(icon: Icons.language, title: 'Language', trailing: 'English', onTap: () {}),
                const SettingsDivider(),
                SettingsMenuTile(icon: Icons.notifications_none_rounded, title: 'Notifications', trailing: 'On', onTap: () {}),
              ],
            ),
          ),

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
          const Divider(),
          const SizedBox(height: 32),

          // 4. 계정 관리
          if (authProvider.isAuthenticated)
            Center(
              child: TextButton(
                onPressed: () => _showDeleteAccountDialog(context, authProvider),
                child: Text(
                  'Delete Account',
                  style: TextStyle(color: Colors.red.shade300, fontSize: 13),
                ),
              ),
            ),
          const SizedBox(height: 40),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Account'),
        content: const Text('Are you sure you want to delete your account?\nAll your profile information will be permanently removed.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await auth.deleteAccount();
                if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Account has been deleted.')));
              } catch (e) {
                if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}