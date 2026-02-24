import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/notice_provider.dart';
import '../../utils/app_colors.dart';
import 'notice_detail_screen.dart';

class NoticeScreen extends StatefulWidget {
  const NoticeScreen({super.key});

  @override
  State<NoticeScreen> createState() => _NoticeScreenState();
}

class _NoticeScreenState extends State<NoticeScreen> {
  @override
  void initState() {
    super.initState();
    // 화면 로드 시 공지사항 가져오기 (메서드명 수정: refreshNotices)
    WidgetsBinding.instance.addPostFrameCallback((_) {
    });
  }

  String _formatDate(DateTime date) {
    return "${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NoticeProvider>();

    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final notices = provider.notices;

    if (notices.isEmpty) {
      return const Center(child: Text("No notices yet."));
    }

    return ListView.builder(
      itemCount: notices.length,
      itemBuilder: (context, index) {
        final notice = notices[index];

        return ListTile(
          title: Text(
            notice.title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(_formatDate(notice.createdAt)),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => NoticeDetailScreen(notice: notice),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return ListView(
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