import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'privacy_policy_screen.dart';
import 'contact_screen.dart';

import '../admin/admin_dashboard_screen.dart';
import '../../utils/app_colors.dart';
import '../../widgets/settings/settings_widgets.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // AuthProvider의 상태 변화를 감시합니다.
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.normal),
        ),
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
                // 알림 설정 토글 스위치 적용
                SettingsMenuTile(
                  icon: Icons.notifications_none_rounded,
                  title: 'Notifications',
                  trailing: Switch(
                    value: authProvider.isNotificationsEnabled,
                    // 스위치 조작 시 AuthProvider의 토글 함수 호출
                    onChanged: authProvider.isAuthenticated
                        ? (val) => authProvider.toggleNotifications(val)
                        : null, // 로그인 안 된 경우 비활성화
                    activeColor: AppColors.knuRed,
                    activeTrackColor: AppColors.knuRed.withOpacity(0.2),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 4. 지원 섹션
          const SettingsSectionHeader(title: 'Support'),
          SettingsGroupCard(
            child: Column(
              children: [
                SettingsMenuTile(
                  icon: Icons.privacy_tip_outlined,
                  title: 'Privacy Policy',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PrivacyPolicyScreen(),
                      ),
                    );
                  },
                ),
                const SettingsDivider(),
                SettingsMenuTile(
                  icon: Icons.mail_outline,
                  title: 'Contact Us',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ContactScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 5. 계정 관리
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

  // 계정 삭제 확인 다이얼로그 (생략 없이 유지)
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