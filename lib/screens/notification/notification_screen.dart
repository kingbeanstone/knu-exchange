import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/community_provider.dart';
import '../../models/notification_item.dart';
import '../../utils/app_colors.dart';
import '../community/post_detail_screen.dart';

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
          item.type == NotificationType.comment ? Icons.comment_outlined : Icons.favorite_border,
          color: item.isRead ? Colors.grey : AppColors.knuRed,
          size: 20,
        ),
      ),
      title: RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.black, fontSize: 14),
          children: [
            TextSpan(
                text: item.senderName,
                style: const TextStyle(fontWeight: FontWeight.bold)
            ),
            TextSpan(text: ' ${item.message}'),
          ],
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
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
      onTap: () => _handleNotificationTap(context, item, userId),
    );
  }

  // [수정] 알림 클릭 시 로직 강화: 메모리에 없는 포스트도 서버에서 가져와 이동
  Future<void> _handleNotificationTap(BuildContext context, NotificationItem item, String userId) async {
    final notifProvider = context.read<NotificationProvider>();
    final communityProvider = context.read<CommunityProvider>();

    // 1. 읽음 처리
    notifProvider.markAsRead(userId, item.id);

    // 2. 게시글 상세 페이지로 이동 시도
    try {
      // 로딩 다이얼로그 표시 (서버에서 게시글을 가져올 수도 있으므로)
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      // CommunityProvider에 추가된 fetchPostById 사용
      final targetPost = await communityProvider.fetchPostById(item.postId);

      if (context.mounted) Navigator.pop(context); // 로딩 닫기

      if (targetPost != null && context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PostDetailScreen(post: targetPost)),
        );
      } else {
        throw Exception("Post not found");
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // 로딩 닫기
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('The post has been deleted or cannot be found.'))
        );
      }
    }
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
    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    return '${date.month}/${date.day}';
  }
}