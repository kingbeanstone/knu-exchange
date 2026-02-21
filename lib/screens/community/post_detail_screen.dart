import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/post.dart';
import '../../providers/community_provider.dart';
import '../../providers/comment_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_colors.dart';
import '../../widgets/community/comment_section.dart';
import '../../widgets/community/post_action_bar.dart';
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
    final communityProvider = Provider.of<CommunityProvider>(context, listen: false);
    final commentProvider = Provider.of<CommentProvider>(context, listen: false);

    await Future.wait([
      communityProvider.getPostDetail(widget.post.id).then((p) {
        if (p != null && mounted) setState(() => _currentPost = p);
      }),
      commentProvider.loadComments(widget.post.id),
    ]);

    if (mounted) setState(() => _isFetching = false);
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
                await Provider.of<CommunityProvider>(context, listen: false).removePost(_currentPost.id);
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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('신고를 위해 로그인이 필요합니다.')));
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

    // [수정] 본인의 글이거나 관리자(isAdmin)인 경우 삭제 권한 부여
    final bool canDelete = auth.isAuthenticated && (auth.user?.uid == _currentPost.authorId || auth.isAdmin);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Post Detail'),
        backgroundColor: AppColors.knuRed,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // [수정] 권한이 있으면 삭제 아이콘, 없으면 신고 아이콘 노출
          if (canDelete)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _confirmDelete,
              tooltip: 'Delete post',
            )
          else
            IconButton(
              icon: const Icon(Icons.report_problem_outlined),
              onPressed: _showReportDialog,
              tooltip: 'Report this post',
            ),
        ],
      ),
      body: _isFetching
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const Divider(height: 40),
                  SelectionArea(
                      child: Text(_currentPost.content, style: const TextStyle(fontSize: 16, height: 1.7))
                  ),
                  const SizedBox(height: 40),
                  CommentSection(postId: _currentPost.id),
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

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: AppColors.knuRed.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
          child: Text(_currentPost.categoryLabel.toUpperCase(), style: const TextStyle(color: AppColors.knuRed, fontSize: 11, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 16),
        Text(_currentPost.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, height: 1.3)),
        const SizedBox(height: 20),
        Row(children: [
          const CircleAvatar(backgroundColor: AppColors.lightGrey, child: Icon(Icons.person, color: Colors.grey)),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(_currentPost.author, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            Text('${_currentPost.createdAt.year}.${_currentPost.createdAt.month}.${_currentPost.createdAt.day}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ]),
        ]),
      ],
    );
  }
}