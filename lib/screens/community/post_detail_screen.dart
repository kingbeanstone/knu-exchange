import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/post.dart';
import '../../providers/community_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/like_provider.dart'; // LikeProvider 추가
import '../../utils/app_colors.dart';
import '../settings/login_screen.dart';

class PostDetailScreen extends StatelessWidget {
  final Post post;

  const PostDetailScreen({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Consumer<CommunityProvider>(
      builder: (context, communityProvider, child) {
        final currentPost = communityProvider.posts.firstWhere(
              (p) => p.id == post.id,
          orElse: () => post,
        );

        return Scaffold(
          appBar: AppBar(
            title: const Text('Post Detail'),
            backgroundColor: AppColors.knuRed,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCategoryTag(currentPost.categoryLabel),
                  const SizedBox(height: 16),
                  Text(
                    currentPost.title,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, height: 1.3),
                  ),
                  const SizedBox(height: 20),
                  _buildAuthorInfo(currentPost),
                  const Divider(height: 40),
                  SelectionArea(
                    child: Text(
                      currentPost.content,
                      style: const TextStyle(fontSize: 16, height: 1.7, color: Colors.black87),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          bottomNavigationBar: _buildBottomBar(context, currentPost),
        );
      },
    );
  }

  Widget _buildCategoryTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.knuRed.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(color: AppColors.knuRed, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildAuthorInfo(Post post) {
    return Row(
      children: [
        const CircleAvatar(
          backgroundColor: AppColors.lightGrey,
          child: Icon(Icons.person, color: Colors.grey),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(post.author, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            Text(
              '${post.createdAt.year}.${post.createdAt.month}.${post.createdAt.day}',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context, Post currentPost) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final likeProvider = Provider.of<LikeProvider>(context, listen: false); // LikeProvider 가져오기

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade200)),
        ),
        child: Row(
          children: [
            // 좋아요 버튼 (LikeProvider 사용)
            StreamBuilder<bool>(
                stream: likeProvider.getIsLikedStream(currentPost.id, authProvider.user?.uid ?? ""),
                builder: (context, snapshot) {
                  final isLiked = snapshot.data ?? false;
                  return InkWell(
                    onTap: () async {
                      if (!authProvider.isAuthenticated) {
                        _showLoginRequest(context);
                        return;
                      }
                      try {
                        await likeProvider.toggleLike(currentPost.id, authProvider.user!.uid);
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Action failed: $e")),
                          );
                        }
                      }
                    },
                    child: Row(
                      children: [
                        Icon(
                          isLiked ? Icons.favorite : Icons.favorite_border,
                          color: AppColors.knuRed,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${currentPost.likes}',
                          style: const TextStyle(color: AppColors.knuRed, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                  );
                }
            ),
            const Spacer(),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.share_outlined, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  void _showLoginRequest(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Log in is required to like."),
        action: SnackBarAction(
          label: "Login",
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
          },
        ),
      ),
    );
  }
}