import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/notice_provider.dart';
import '../../utils/app_colors.dart';

class NoticeScreen extends StatefulWidget {
  const NoticeScreen({super.key});

  @override
  State<NoticeScreen> createState() => _NoticeScreenState();
}

class _NoticeScreenState extends State<NoticeScreen> {
  @override
  void initState() {
    super.initState();
    // 화면 로드 시 공지사항 가져오기
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NoticeProvider>().fetchNotices();
    });
  }

  @override
  Widget build(BuildContext context) {
    final noticeProvider = context.watch<NoticeProvider>();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('공지사항'),
        backgroundColor: AppColors.knuRed,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () => noticeProvider.fetchNotices(),
        child: noticeProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : noticeProvider.notices.isEmpty
            ? _buildEmptyState()
            : ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: noticeProvider.notices.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final notice = noticeProvider.notices[index];
            return Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey[200]!),
              ),
              child: ExpansionTile(
                title: Text(
                  notice.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    DateFormat('yyyy.MM.dd').format(notice.createdAt),
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
                childrenPadding: const EdgeInsets.all(16),
                expandedAlignment: Alignment.topLeft,
                children: [
                  Text(
                    notice.content,
                    style: const TextStyle(fontSize: 14, height: 1.6),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView( // RefreshIndicator 작동을 위해 ListView 사용
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.3),
        const Center(
          child: Column(
            children: [
              Icon(Icons.notifications_none, size: 60, color: Colors.grey),
              SizedBox(height: 16),
              Text('등록된 공지사항이 없습니다.', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ],
    );
  }
}