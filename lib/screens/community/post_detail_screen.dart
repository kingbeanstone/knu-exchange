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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initData();
    });
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
      builder: (context) => ReportDialog(
        targetId: _currentPost.id,
        targetType: 'post',
        reportedUserId: _currentPost.authorId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final bool isAuthor = auth.isAuthenticated && auth.user?.uid == _currentPost.authorId;
    final bool canDelete = isAuthor || auth.isAdmin;

    return Scaffold(
      backgroundColor: Colors.white,
      // [중요] 키보드가 올라올 때 Scaffold가 바닥을 밀어올리도록 설정
      resizeToAvoidBottomInset: true,
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
          : Column( // [핵심 변경] 전체를 Column으로 구성
        children: [
          Expanded( // [핵심 변경] 본문 영역을 Expanded로 감싸 가변 높이 대응
            child: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
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

                    // 좋아요 및 댓글 수 액션 바
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
          ),
          // [핵심 변경] 입력창을 body의 Column 마지막 자식으로 배치
          // 이렇게 하면 Scaffold의 높이가 키보드에 의해 줄어들 때 함께 위로 밀려 올라갑니다.
          CommentInput(postId: _currentPost.id),
        ],
      ),
    );
  }
}