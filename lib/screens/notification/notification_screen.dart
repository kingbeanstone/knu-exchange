import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/community_provider.dart';
import '../../models/notification_item.dart';
import '../../utils/app_colors.dart';
import '../community/post_detail_screen.dart';
import '../notice/notice_detail_screen.dart';
import '../../widgets/settings/settings_profile_widgets.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final notifProvider = Provider.of<NotificationProvider>(context);

    if (!auth.isAuthenticated || auth.user == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Notifications'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          centerTitle: true,
        ),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: SettingsLoginPrompt(),
          ),
        ),
      );
    }

    final String currentUserId = auth.user!.uid;

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
              onPressed: () => notifProvider.markAllAsRead(currentUserId),
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
          return _buildNotificationItem(context, item, currentUserId);
        },
      ),
    );
  }

  Widget _buildNotificationItem(BuildContext context, NotificationItem item, String userId) {
    return ListTile(
      // [수정] withOpacity 대신 withValues 사용 (경고 해결)
      tileColor: item.isRead ? Colors.white : AppColors.knuRed.withValues(alpha: 0.05),
      leading: CircleAvatar(
        // [수정] withOpacity 대신 withValues 사용 (경고 해결)
        backgroundColor: item.isRead ? AppColors.lightGrey : AppColors.knuRed.withValues(alpha: 0.1),
        child: Icon(
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
        context.read<NotificationProvider>().markAsRead(userId, item.id);

        if (item.type == NotificationType.system || item.postId.startsWith('notice_')) {
          if (context.mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => NoticeDetailScreen(noticeId: item.postId)),
            );
          }
        } else {
          final communityProvider = context.read<CommunityProvider>();
          // [참고] CommunityProvider에 fetchPostById가 정의되어 있어야 에러가 나지 않습니다.
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