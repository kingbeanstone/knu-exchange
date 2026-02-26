import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 클립보드 기능을 위해 필요
import 'package:url_launcher/url_launcher.dart'; // 링크 이동을 위해 필요

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  // 이메일 복사 함수
  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('이메일 주소가 복사되었습니다.')),
    );
  }

  // URL 실행 함수 (인스타그램)
  Future<void> _launchInstagram() async {
    final Uri url = Uri.parse('https://www.instagram.com/knu_exchange/');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact Us'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 이메일 섹션 (클릭 시 복사)
            InkWell(
              onTap: () => _copyToClipboard(context, 'TeamMillionM@gmail.com'),
              borderRadius: BorderRadius.circular(15),
              child: _buildContactItem(
                icon: Icons.email_outlined,
                title: 'Email (Tap to Copy)',
                content: 'TeamMillionM@gmail.com',
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(height: 20),
            // 인스타그램 섹션 (클릭 시 이동)
            InkWell(
              onTap: _launchInstagram,
              borderRadius: BorderRadius.circular(15),
              child: _buildContactItem(
                icon: Icons.camera_alt_outlined,
                title: 'Instagram',
                content: '@knu_exchange',
                color: Colors.pinkAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String title,
    required String content,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Icon(icon, size: 40, color: color),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              Text(
                content,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const Spacer(),
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        ],
      ),
    );
  }
}