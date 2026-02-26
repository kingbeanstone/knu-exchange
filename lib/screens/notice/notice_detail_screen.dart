import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import '../../utils/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/notice/notice_detail_header.dart';
import '../../widgets/notice/notice_detail_body.dart';
import 'edit_notice_screen.dart';

class NoticeDetailScreen extends StatelessWidget {
  final String noticeId;

  const NoticeDetailScreen({
    super.key,
    required this.noticeId,
  });

  Future<void> _deleteNotice(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Notice'),
        content: const Text('Are you sure you want to delete this notice?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: AppColors.knuRed)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instance
          .collection('notices')
          .doc(noticeId)
          .delete();

      if (context.mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Notice Details'),
        backgroundColor: AppColors.knuRed,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        actions: [
          if (auth.isAdmin) _buildAdminMenu(context),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notices')
            .doc(noticeId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.knuRed));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Notice not found.'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                NoticeDetailHeader(
                  title: data['title'] ?? '',
                  createdAt: data['createdAt'] as Timestamp,
                ),
                const Divider(height: 1, thickness: 1, color: AppColors.lightGrey),
                NoticeDetailBody(content: data['content'] ?? ''),
                const SizedBox(height: 60),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAdminMenu(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('notices')
          .doc(noticeId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();
        final data = snapshot.data!.data() as Map<String, dynamic>?;
        if (data == null) return const SizedBox();

        return PopupMenuButton<String>(
          icon: const Icon(Icons.more_horiz),
          onSelected: (value) {
            if (value == 'edit') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditNoticeScreen(
                    noticeId: noticeId,
                    initialTitle: data['title'] ?? '',
                    initialContent: data['content'] ?? '',
                  ),
                ),
              );
            } else if (value == 'delete') {
              _deleteNotice(context);
            }
          },
          itemBuilder: (context) => const [
            PopupMenuItem(value: 'edit', child: Text('Edit')),
            PopupMenuItem(
              value: 'delete',
              child: Text('Delete', style: TextStyle(color: AppColors.knuRed)),
            ),
          ],
        );
      },
    );
  }
}