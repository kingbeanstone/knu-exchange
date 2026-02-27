import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'privacy_policy_screen.dart';
import 'contact_screen.dart';

import '../admin/admin_dashboard_screen.dart';
import '../../utils/app_colors.dart';
// 분리된 위젯 파일들로 임포트 변경
import '../../widgets/settings/settings_common_widgets.dart';
import '../../widgets/settings/settings_profile_widgets.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 18,
          ),
        ),
        backgroundColor: AppColors.knuRed,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false, // 통일성을 위해 왼쪽 정렬
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 24),
        children: [
          // 1. Profile Section
          const SettingsSectionHeader(title: 'Account'),
          SettingsGroupCard(
            child: authProvider.isAuthenticated
                ? SettingsProfileContent(auth: authProvider)
                : const SettingsLoginPrompt(),
          ),

          const SizedBox(height: 32),

          // 2. Admin Section
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
            const SizedBox(height: 32),
          ],

          // 3. Preferences Section
          const SettingsSectionHeader(title: 'Preferences'),
          SettingsGroupCard(
            child: Column(
              children: [
                SettingsMenuTile(
                  icon: Icons.notifications_none_rounded,
                  iconColor: Colors.orange,
                  title: 'Notifications',
                  trailing: Switch(
                    value: authProvider.isNotificationsEnabled,
                    onChanged: authProvider.isAuthenticated
                        ? (val) => authProvider.toggleNotifications(val)
                        : null,
                    activeColor: AppColors.knuRed,
                    activeTrackColor: AppColors.knuRed.withOpacity(0.2),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // 4. Support Section
          const SettingsSectionHeader(title: 'Support'),
          SettingsGroupCard(
            child: Column(
              children: [
                SettingsMenuTile(
                  icon: Icons.privacy_tip_outlined,
                  iconColor: Colors.green,
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
                  iconColor: Colors.blue,
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
          const SizedBox(height: 32),

          // 5. Account Management
          if (authProvider.isAuthenticated)
            Center(
              child: TextButton(
                onPressed: () => _showDeleteAccountDialog(context, authProvider),
                child: Text(
                  'Delete Account',
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                ),
              ),
            ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account?\nAll your profile information will be permanently removed.',
          style: TextStyle(height: 1.5),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey))
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await auth.deleteAccount();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Account has been deleted.'))
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e'))
                  );
                }
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}