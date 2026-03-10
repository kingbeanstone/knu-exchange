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

  // [수정] 차단 다이얼로그 - 팝업 즉시 닫기 및 화면 종료 로직 강화
  void _showBlockDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Block User'),
        content: Text('Block "${_currentPost.authorName}"? \nYou will no longer see any posts from this user.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              final auth = Provider.of<AuthProvider>(context, listen: false);
              final community = Provider.of<CommunityProvider>(context, listen: false);

              if (auth.user == null) return;

              // 1. 차단 팝업창을 즉시 닫음 (사용자 경험 개선)
              Navigator.pop(ctx);

              // 2. 차단 실행 및 리스트에서 즉시 제거 (애플 Guideline 1.2 준수)
              // 이제 Mixin에서 finally로 로딩을 해제하므로 빙글빙글이 멈춥니다.
              await community.blockUser(
                currentUserId: auth.user!.uid,
                blockedUserId: _currentPost.authorId,
                blockedUserName: _currentPost.authorName,
                onBlockedUI: () {
                  community.removePostsByAuthor(_currentPost.authorId);
                },
              );

              // 3. 내 로컬 차단 목록 최신화
              await auth.refreshUserModel();

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('User blocked and content removed.'))
                );
                // 4. 상세 페이지 닫기 (차단한 유저의 글이므로 즉시 퇴장)
                Navigator.pop(context);
              }
            },
            child: const Text('Block', style: TextStyle(color: AppColors.knuRed)),
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
          else ...[
            // 차단 버튼 추가 (애플 권장사항)
            IconButton(
              icon: const Icon(Icons.block, color: Colors.grey),
              onPressed: _showBlockDialog,
            ),
            IconButton(
              icon: const Icon(Icons.report_problem_outlined, color: Colors.grey),
              onPressed: _showReportDialog,
            ),
          ],
        ],
      ),
      body: _isFetching
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PostDetailHeader(post: _currentPost),
                    const Divider(thickness: 1, height: 1, color: AppColors.lightGrey),
                    PostDetailContent(
                      content: _currentPost.content,
                      imageUrls: _currentPost.imageUrls,
                    ),
                    PostActionBar(post: _currentPost),
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
          CommentInput(postId: _currentPost.id),
        ],
      ),
    );
  }
}