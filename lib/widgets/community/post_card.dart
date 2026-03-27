import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/post.dart';
import '../../utils/app_colors.dart';
import '../../utils/date_formatter.dart';
import '../../screens/community/post_detail_screen.dart';
import '../../providers/community_provider.dart';
import '../../providers/auth_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PostCard extends StatelessWidget {
  static final Set<String> _hiddenPosts = {};
  final Post post;

  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    if (_hiddenPosts.contains(post.id)) {
      return const SizedBox();
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // [수정] 사진이 있을 때만 캐싱을 시도하도록 방어 코드 추가 (Crash 방지)
            if (post.imageUrls.isNotEmpty) {
              precacheImage(CachedNetworkImageProvider(post.imageUrls.first), context);
            }

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PostDetailScreen(post: post),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.knuRed.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        post.categoryLabel.toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.knuRed,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      DateFormatter.formatRelativeTime(post.createdAt),
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const Spacer(),
                    Transform.translate(
                      offset: const Offset(4, 0),
                      child: PopupMenuButton<String>(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(Icons.more_vert, size: 18, color: Colors.grey),
                        onSelected: (value) {
                          if (value == 'hide') {
                            final community = Provider.of<CommunityProvider>(context, listen: false);
                            community.removePostsByAuthor(post.authorId);
                            _hiddenPosts.add(post.id);
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Post hidden')));
                          }
                          else if (value == 'block') {
                            _showBlockDialog(context, post.authorId, post.author);
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'hide',
                            child: Text('Hide Post'),
                          ),
                          const PopupMenuItem(
                            value: 'block',
                            child: Text('Block User', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            post.title,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkGrey,
                              height: 1.3,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            post.content,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (post.imageUrls.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(left: 12),
                        child: Hero(
                          tag: post.imageUrls.first,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: CachedNetworkImage(
                              imageUrl: post.imageUrls.first,
                              width: 70,
                              height: 70,
                              fit: BoxFit.cover,
                              memCacheWidth: 200,
                              placeholder: (context, url) => Container(
                                width: 70,
                                height: 70,
                                color: Colors.grey[100],
                              ),
                              errorWidget: (context, url, error) => Container(
                                width: 70,
                                height: 70,
                                color: Colors.grey[100],
                                child: const Icon(Icons.image_not_supported, color: Colors.grey, size: 20),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.person_outline, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      post.author,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const Spacer(),
                    _buildStatItem(Icons.favorite_border, post.likes.toString()),
                    const SizedBox(width: 12),
                    _buildStatItem(Icons.chat_bubble_outline, post.comments.toString()),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showBlockDialog(BuildContext context, String authorId, String authorName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Block User'),
        content: Text('Do you want to block "$authorName"? \nAll content from this user will be hidden instantly.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              final auth = Provider.of<AuthProvider>(context, listen: false);
              final community = Provider.of<CommunityProvider>(context, listen: false);

              if (auth.user == null) return;
              Navigator.pop(ctx);

              await community.blockUser(
                currentUserId: auth.user!.uid,
                blockedUserId: authorId,
                blockedUserName: authorName,
                onBlockedUI: () {
                  community.removePostsByAuthor(authorId);
                },
              );

              await auth.refreshUserModel();

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('User blocked successfully.'))
                );
              }
            },
            child: const Text('Block', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String count) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey[400]),
        const SizedBox(width: 4),
        Text(
          count,
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ],
    );
  }
}