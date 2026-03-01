import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/community_provider.dart';
import '../../models/notification_item.dart';
import '../../utils/app_colors.dart';
import '../community/post_detail_screen.dart';
import '../notice/notice_detail_screen.dart'; // [추가] 공지 상세 화면 임포트

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final notifProvider = Provider.of<NotificationProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        actions: [
          if (notifProvider.notifications.isNotEmpty)
            TextButton(
              onPressed: () => notifProvider.markAllAsRead(auth.user!.uid),
              child: const Text('Mark all as read', style: TextStyle(color: Colors.grey)),
            ),
        ],
      ),
      body: notifProvider.notifications.isEmpty
          ? _buildEmptyState()
          : ListView.separated(
        itemCount: notifProvider.notifications.length,
        separatorBuilder: (context, index) => const Divider(height: 1, color: AppColors.lightGrey),
        itemBuilder: (context, index) {
          final item = notifProvider.notifications[index];
          return _buildNotificationItem(context, item, auth.user!.uid);
        },
      ),
    );
  }

  Widget _buildNotificationItem(BuildContext context, NotificationItem item, String userId) {
    return ListTile(
      tileColor: item.isRead ? Colors.white : AppColors.knuRed.withOpacity(0.05),
      leading: CircleAvatar(
        backgroundColor: item.isRead ? AppColors.lightGrey : AppColors.knuRed.withOpacity(0.1),
        child: Icon(
          // [수정] 알림 타입에 따른 아이콘 분기
          item.type == NotificationType.comment
              ? Icons.comment_outlined
              : (item.type == NotificationType.system ? Icons.campaign_rounded : Icons.notifications_none),
          color: item.isRead ? Colors.grey : AppColors.knuRed,
          size: 20,
        ),
      ),
      title: RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.black, fontSize: 14),
          children: [
            TextSpan(text: item.senderName, style: const TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: ' ${item.message}'),
          ],
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          if (item.postTitle.isNotEmpty)
            Text(
              'on "${item.postTitle}"',
              style: const TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          const SizedBox(height: 4),
          Text(
            _formatDate(item.createdAt),
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ],
      ),
      onTap: () async {
        // 1. 읽음 처리
        context.read<NotificationProvider>().markAsRead(userId, item.id);

        // 2. [수정] 알림 타입에 따른 화면 이동 로직
        if (item.type == NotificationType.system || item.postId.startsWith('notice_')) {
          // 공지사항인 경우 (postId가 notice_로 시작하거나 system 타입인 경우)
          if (context.mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => NoticeDetailScreen(noticeId: item.postId)),
            );
          }
        } else {
          // 일반 커뮤니티 게시글인 경우
          final communityProvider = context.read<CommunityProvider>();
          final targetPost = await communityProvider.fetchPostById(item.postId);

          if (targetPost != null && context.mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PostDetailScreen(post: targetPost)),
            );
          }
        }
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none, size: 64, color: Colors.grey[200]),
          const SizedBox(height: 16),
          const Text('No notifications yet', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    return '${date.month}/${date.day}';
  }
}