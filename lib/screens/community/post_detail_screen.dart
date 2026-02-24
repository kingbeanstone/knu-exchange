import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/post.dart';
import '../../providers/community_provider.dart';
import '../../providers/comment_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_colors.dart';
import '../../widgets/community/comment_section.dart';
import '../../widgets/community/post_action_bar.dart';
import '../../widgets/community/post_detail_header.dart';
import '../../widgets/community/post_detail_content.dart';
import '../../widgets/community/comment_input.dart'; // [추가] 누락된 임포트 확인
import '../../widgets/report_dialog.dart';

class PostDetailScreen extends StatefulWidget {
  final Post post;
  const PostDetailScreen({super.key, required this.post});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  late Post _currentPost;
  bool _isFetching = true;

  @override
  void initState() {
    super.initState();
    _currentPost = widget.post;
    _initData();
  }

  Future<void> _initData() async {
    _currentPost = widget.post;
    await context.read<CommentProvider>().loadComments(widget.post.id);
    if (mounted) {
      setState(() => _isFetching = false);
    }
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Post'),
        content: const Text('Are you sure you want to delete this post?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await Provider.of<CommunityProvider>(context, listen: false)
                    .deletePost(widget.post.id);
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Post deleted.')));
                }
              } catch (e) {
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Delete failed: $e')));
              }
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.knuRed)),
          ),
        ],
      ),
    );
  }

  void _showReportDialog() {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (!auth.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Login is required to report.')));
      return;
    }
    showDialog(
      context: context,
      builder: (context) => ReportDialog(targetId: _currentPost.id, targetType: 'post'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final bool canDelete = auth.isAuthenticated && (auth.user?.uid == _currentPost.authorId || auth.isAdmin);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Post'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        actions: [
          if (canDelete)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.grey),
              onPressed: _confirmDelete,
            )
          else
            IconButton(
              icon: const Icon(Icons.report_problem_outlined, color: Colors.grey),
              onPressed: _showReportDialog,
            ),
        ],
      ),
      body: _isFetching
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PostDetailHeader(post: _currentPost),
                  const Divider(thickness: 1, height: 1, color: AppColors.lightGrey),
                  // [수정] 이미지 리스트 전달
                  PostDetailContent(
                    content: _currentPost.content,
                    imageUrls: _currentPost.imageUrls,
                  ),
                  Container(height: 8, color: AppColors.lightGrey),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                    child: CommentSection(postId: _currentPost.id),
                  ),
                ],
              ),
            ),
          ),
          CommentInput(postId: _currentPost.id),
        ],
      ),
      bottomNavigationBar: PostActionBar(post: _currentPost),
    );
  }
}