import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/community_provider.dart';
import '../../models/notification_item.dart';
import '../../utils/app_colors.dart';
import '../community/post_detail_screen.dart';
import '../notice/notice_detail_screen.dart';
import '../../widgets/settings/settings_profile_widgets.dart'; // SettingsLoginPrompt 사용

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final notifProvider = Provider.of<NotificationProvider>(context);

    // [핵심 수정] 비로그인 상태에서는 알림 목록 대신 로그인 안내 화면을 표시하여 Null check 에러를 방지합니다.
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
            child: SettingsLoginPrompt(), // 설정 탭에서 사용하는 로그인 유도 UI 재사용
          ),
        ),
      );
    }

    // 로그인된 상태에서는 안전하게 uid를 참조할 수 있습니다.
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
      tileColor: item.isRead ? Colors.white : AppColors.knuRed.withOpacity(0.05),
      leading: CircleAvatar(
        backgroundColor: item.isRead ? AppColors.lightGrey : AppColors.knuRed.withOpacity(0.1),
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