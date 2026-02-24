import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notice_provider.dart';
import '../../utils/app_colors.dart';
import 'notice_detail_screen.dart';
import 'create_notice_screen.dart';

class NoticeScreen extends StatefulWidget {
  const NoticeScreen({super.key});

  @override
  State<NoticeScreen> createState() => _NoticeScreenState();
}

class _NoticeScreenState extends State<NoticeScreen> {
  String _formatDate(DateTime date) {
    return "${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NoticeProvider>();
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Notice'),
        backgroundColor: AppColors.knuRed,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (auth.isAdmin)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CreateNoticeScreen()),
                );
              },
            ),
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.notices.isEmpty
          ? const Center(child: Text("No notices yet."))
          : ListView.separated(
        padding: EdgeInsets.zero,
        itemCount: provider.notices.length,
        // 1. 구분선 설정: 더 진하게, 양 끝까지 닿도록 수정
        separatorBuilder: (context, index) => Divider(
          height: 1,
          thickness: 1,      // 선 두께를 1로 강화
          indent: 0,         // 왼쪽 여백 제거 (화면 끝까지)
          endIndent: 0,      // 오른쪽 여백 제거 (화면 끝까지)
          color: Colors.grey[300], // 색상을 조금 더 진하게 변경
        ),
        itemBuilder: (context, index) {
          final notice = provider.notices[index];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            // 2. 제목 설정: 한 줄로 고정하고 넘치면 ... 처리
            title: Text(
              notice.title,
              maxLines: 1, // 무조건 한 줄로 고정
              overflow: TextOverflow.ellipsis, // 길면 마지막에 ... 표시
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                _formatDate(notice.createdAt),
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => NoticeDetailScreen(noticeId: notice.id),
                ),
              );
            },
          );
        },
      ),
    );
  }
}