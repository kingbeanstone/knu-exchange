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
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Notice'),
        backgroundColor: AppColors.knuRed,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (context.watch<AuthProvider>().isAdmin)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CreateNoticeScreen(),
                  ),
                );
              },
            ),
        ],
      ),
      body: Column(
        children: [
          const Divider(height: 1),
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : provider.notices.isEmpty
                ? const Center(child: Text("No notices yet."))
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.notices.length,
              itemBuilder: (context, index) {
                final notice = provider.notices[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: LayoutBuilder(
                      builder: (context, constraints) {
                        const textStyle = TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        );

                        final maxWidth = constraints.maxWidth - 50; // 🔥 점 3개 공간 확보

                        final textPainter = TextPainter(
                          text: TextSpan(text: notice.title, style: textStyle),
                          maxLines: 1,
                          textDirection: TextDirection.ltr,
                        )..layout(maxWidth: maxWidth);

                        if (!textPainter.didExceedMaxLines) {
                          return Text(
                            notice.title,
                            maxLines: 1,
                            style: textStyle,
                          );
                        }

                        int endIndex = notice.title.length;
                        String truncated = notice.title;

                        while (endIndex > 0) {
                          endIndex--;
                          truncated = notice.title.substring(0, endIndex) + "...";

                          textPainter.text = TextSpan(text: truncated, style: textStyle);
                          textPainter.layout(maxWidth: maxWidth);

                          if (!textPainter.didExceedMaxLines) break;
                        }

                        return Text(
                          truncated,
                          maxLines: 1,
                          style: textStyle,
                        );
                      },
                    ),
                    subtitle:
                    Text(_formatDate(notice.createdAt)),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => NoticeDetailScreen(
                            noticeId: notice.id,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}