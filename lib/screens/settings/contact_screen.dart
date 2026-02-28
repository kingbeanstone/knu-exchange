import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/app_colors.dart';
import '../../widgets/settings/settings_common_widgets.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  // 이메일 복사 함수
  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Email address copied to clipboard.'),
        backgroundColor: Colors.black87,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // URL 실행 함수 (인스타그램)
  Future<void> _launchInstagram() async {
    final Uri url = Uri.parse('https://www.instagram.com/knu_exchange/');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // 앱 전체 공통 배경색
      appBar: AppBar(
        title: const Text(
          'Contact Us',
          style: TextStyle(fontWeight: FontWeight.normal, fontSize: 18),
        ),
        backgroundColor: AppColors.knuRed,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false, // 왼쪽 정렬 통일
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 24),
        children: [
          const SettingsSectionHeader(title: 'Get in Touch'),

          SettingsGroupCard(
            child: Column(
              children: [
                // 이메일 지원 타일 (주소 노출)
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.email_outlined, color: Colors.blueAccent, size: 20),
                  ),
                  title: const Text(
                    'Email Support',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.darkGrey),
                  ),
                  subtitle: const Text(
                    'TeamMillionM@gmail.com',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  trailing: TextButton(
                    onPressed: () => _copyToClipboard(context, 'TeamMillionM@gmail.com'),
                    child: const Text(
                      'Copy',
                      style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),

                const SettingsDivider(),

                // 인스타그램 메뉴
                SettingsMenuTile(
                  icon: Icons.camera_alt_outlined,
                  iconColor: Colors.pinkAccent,
                  title: 'Official Instagram',
                  onTap: _launchInstagram,
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // 팀원 소개 섹션
          const SettingsSectionHeader(title: 'Meet the Team'),
          SettingsGroupCard(
            child: Column(
              children: [
                _buildTeamTile(
                  name: 'Shin juyeon',
                  role: 'Project Manager',
                  email: '102wndus@naver.com',
                ),
                const SettingsDivider(),
                // [수정] 김대한 개발자 이메일 추가
                _buildTeamTile(
                  name: 'Kim daehan',
                  role: 'Developer',
                  email: 'Kimtony598@gmail.com',
                ),
                const SettingsDivider(),
                _buildTeamTile(
                  name: '진형준',
                  role: 'Developer',
                  email: 'wlsgudwns112@naver.com',
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // 추가 안내 텍스트
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "We'd love to hear from you!",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkGrey
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "If you have any questions, feedback, or suggestions for the KNU Exchange app, please feel free to reach out. Our team usually responds within 24 hours.",
                  style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      height: 1.5
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 팀원 정보를 표시하는 헬퍼 위젯
  Widget _buildTeamTile({required String name, required String role, String? email}) {
    return ListTile(
      leading: CircleAvatar(
        radius: 18,
        backgroundColor: Colors.grey[200],
        child: const Icon(Icons.person_outline, color: Colors.grey, size: 20),
      ),
      title: Text(
        name,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.darkGrey),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(role, style: const TextStyle(fontSize: 12, color: AppColors.knuRed, fontWeight: FontWeight.w500)),
          if (email != null)
            Text(email, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
    );
  }
}