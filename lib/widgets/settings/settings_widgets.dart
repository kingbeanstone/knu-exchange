import 'package:flutter/material.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_colors.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/settings/profile_edit_screen.dart';

/// 설정 화면의 섹션 제목 위젯
class SettingsSectionHeader extends StatelessWidget {
  final String title;
  const SettingsSectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 28, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.grey.shade600,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

/// 설정 화면의 범용 메뉴 타일 위젯
class SettingsMenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? trailing;
  final VoidCallback onTap;
  final Color? iconColor;

  const SettingsMenuTile({
    super.key,
    required this.icon,
    required this.title,
    this.trailing,
    required this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? Colors.grey.shade700, size: 22),
      title: Text(title, style: const TextStyle(fontSize: 15)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailing != null)
            Text(
              trailing!,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
            ),
          const SizedBox(width: 4),
          Icon(Icons.chevron_right_rounded, size: 20, color: Colors.grey.shade400),
        ],
      ),
      onTap: onTap,
    );
  }
}

/// 설정 항목 사이의 얇은 구분선
class SettingsDivider extends StatelessWidget {
  const SettingsDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Divider(height: 1, thickness: 1, indent: 56, color: Colors.grey.shade50);
  }
}

/// 설정 화면 전용 카드 컨테이너
class SettingsGroupCard extends StatelessWidget {
  final Widget child;
  const SettingsGroupCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        child: child,
      ),
    );
  }
}

/// [신규] 로그인된 사용자의 프로필 위젯
class SettingsProfileContent extends StatelessWidget {
  final AuthProvider auth;
  const SettingsProfileContent({super.key, required this.auth});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.knuRed.withOpacity(0.1),
                child: const Icon(Icons.person, color: AppColors.knuRed, size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(auth.user?.displayName ?? 'Anonymous',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    Text(auth.user?.email ?? '',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileEditScreen())),
                  style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                  child: const Text('Edit Profile'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => auth.logout(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade100,
                    foregroundColor: Colors.black87,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Logout'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// [신규] 로그인이 필요한 상태를 보여주는 위젯
class SettingsLoginPrompt extends StatelessWidget {
  const SettingsLoginPrompt({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.all(16),
      leading: CircleAvatar(backgroundColor: Colors.grey.shade100, child: Icon(Icons.login_rounded, color: Colors.grey.shade600)),
      title: const Text('Login required', style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle: const Text('Sign in to access more features'),
      trailing: ElevatedButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
        style: ElevatedButton.styleFrom(backgroundColor: AppColors.knuRed, foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
        child: const Text('Login'),
      ),
    );
  }
}