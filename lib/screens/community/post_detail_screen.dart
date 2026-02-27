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
import '../../widgets/community/comment_input.dart';
import '../../widgets/report_dialog.dart';
import 'edit_post_screen.dart';

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

  void _syncPostData() {
    final posts = context.read<CommunityProvider>().posts;
    final updated = posts.firstWhere((p) => p.id == _currentPost.id, orElse: () => _currentPost);
    setState(() {
      _currentPost = updated;
    });
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
    final bool isAuthor = auth.isAuthenticated && auth.user?.uid == _currentPost.authorId;
    final bool canDelete = isAuthor || auth.isAdmin;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Post'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        actions: [
          if (isAuthor)
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: Colors.grey),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EditPostScreen(post: _currentPost)),
                );
                _syncPostData();
              },
            ),
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

                  // 게시글 본문 내용
                  PostDetailContent(
                    content: _currentPost.content,
                    imageUrls: _currentPost.imageUrls,
                  ),

                  // [수정] 좋아요 및 댓글 수 액션 바를 본문 바로 아래로 이동
                  // 기존 bottomNavigationBar에서 제거하고 이곳에 배치합니다.
                  PostActionBar(post: _currentPost),

                  // 구분선 및 댓글 섹션
                  Container(height: 8, color: AppColors.lightGrey),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                    child: CommentSection(postId: _currentPost.id),
                  ),
                ],
              ),
            ),
          ),
          // 댓글 입력창은 하단에 고정된 상태 유지
          CommentInput(postId: _currentPost.id),
        ],
      ),
      // [수정] bottomNavigationBar 영역 제거 (본문 내부로 이동됨)
    );
  }
}