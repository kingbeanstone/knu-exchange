import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/post.dart';
import '../../models/comment.dart';
import '../../providers/community_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/like_provider.dart';
import '../../providers/comment_provider.dart';
import '../../utils/app_colors.dart';
import '../settings/login_screen.dart';

class PostDetailScreen extends StatefulWidget {
  final Post post;

  const PostDetailScreen({super.key, required this.post});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  late Post _currentPost;
  bool _isLiked = false;
  bool _isFetching = true;
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _currentPost = widget.post;
    _initData();
  }

  Future<void> _initData() async {
    final communityProvider = Provider.of<CommunityProvider>(context, listen: false);
    final likeProvider = Provider.of<LikeProvider>(context, listen: false);
    final commentProvider = Provider.of<CommentProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // 게시글 상세 & 댓글 로드
    await Future.wait([
      communityProvider.getPostDetail(widget.post.id).then((p) {
        if (p != null && mounted) setState(() => _currentPost = p);
      }),
      commentProvider.loadComments(widget.post.id),
    ]);

    if (authProvider.isAuthenticated && mounted) {
      final liked = await likeProvider.getIsLikedOnce(widget.post.id, authProvider.user!.uid);
      if (mounted) setState(() => _isLiked = liked);
    }

    if (mounted) setState(() => _isFetching = false);
  }

  Future<void> _handleLike() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final likeProvider = Provider.of<LikeProvider>(context, listen: false);

    if (!auth.isAuthenticated) {
      _showLoginRequest(context);
      return;
    }

    setState(() {
      if (_isLiked) {
        _isLiked = false;
        _currentPost = _currentPost.copyWithLikes(_currentPost.likes - 1);
      } else {
        _isLiked = true;
        _currentPost = _currentPost.copyWithLikes(_currentPost.likes + 1);
      }
    });

    try {
      await likeProvider.toggleLike(widget.post.id, auth.user!.uid);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to update like.")));
      }
    }
  }

  Future<void> _handlePostComment() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final commentProvider = Provider.of<CommentProvider>(context, listen: false);

    if (!auth.isAuthenticated) {
      _showLoginRequest(context);
      return;
    }

    final content = _commentController.text.trim();
    if (content.isEmpty) return;

    try {
      final authorName = auth.user?.displayName ?? "User";
      await commentProvider.addComment(widget.post.id, authorName, auth.user!.uid, content);
      _commentController.clear();
      // 댓글 수 UI 반영
      setState(() {
        _currentPost = _currentPost.copyWithComments(_currentPost.comments + 1);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to post comment.")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final commentProvider = Provider.of<CommentProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Detail'),
        backgroundColor: AppColors.knuRed,
        foregroundColor: Colors.white,
        elevation: 0,
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
                  _buildCategoryTag(_currentPost.categoryLabel),
                  const SizedBox(height: 16),
                  Text(_currentPost.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, height: 1.3)),
                  const SizedBox(height: 20),
                  _buildAuthorInfo(_currentPost),
                  const Divider(height: 40),
                  SelectionArea(child: Text(_currentPost.content, style: const TextStyle(fontSize: 16, height: 1.7))),
                  const SizedBox(height: 40),
                  const Text("Comments", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _buildCommentList(commentProvider),
                ],
              ),
            ),
          ),
          _buildCommentInput(),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildCommentList(CommentProvider provider) {
    if (provider.isLoading) return const Center(child: CircularProgressIndicator());
    if (provider.comments.isEmpty) return const Text("No comments yet.", style: TextStyle(color: Colors.grey));

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: provider.comments.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final comment = provider.comments[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(comment.author, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(width: 8),
                Text("${comment.createdAt.month}/${comment.createdAt.day}", style: const TextStyle(color: Colors.grey, fontSize: 11)),
              ],
            ),
            const SizedBox(height: 4),
            Text(comment.content, style: const TextStyle(fontSize: 14)),
          ],
        );
      },
    );
  }

  Widget _buildCommentInput() {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 8, 16, MediaQuery.of(context).viewInsets.bottom + 16),
      decoration: BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Colors.grey.shade200))),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _commentController,
              decoration: const InputDecoration(hintText: "Add a comment...", border: InputBorder.none),
              maxLines: null,
            ),
          ),
          IconButton(
            onPressed: _handlePostComment,
            icon: const Icon(Icons.send, color: AppColors.knuRed),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthorInfo(Post post) => Row(children: [
    const CircleAvatar(backgroundColor: AppColors.lightGrey, child: Icon(Icons.person, color: Colors.grey)),
    const SizedBox(width: 12),
    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(post.author, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
      Text('${post.createdAt.year}.${post.createdAt.month}.${post.createdAt.day}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
    ]),
  ]);

  Widget _buildBottomBar() => SafeArea(
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Colors.grey.shade200))),
      child: Row(children: [
        InkWell(
          onTap: _handleLike,
          child: Row(children: [
            Icon(_isLiked ? Icons.favorite : Icons.favorite_border, color: AppColors.knuRed, size: 24),
            const SizedBox(width: 8),
            Text('${_currentPost.likes}', style: const TextStyle(color: AppColors.knuRed, fontWeight: FontWeight.bold, fontSize: 16)),
          ]),
        ),
        const SizedBox(width: 24),
        Icon(Icons.chat_bubble_outline, color: Colors.grey[600], size: 22),
        const SizedBox(width: 8),
        Text('${_currentPost.comments}', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
        const Spacer(),
        IconButton(onPressed: () {}, icon: const Icon(Icons.share_outlined, color: Colors.grey)),
      ]),
    ),
  );

  Widget _buildCategoryTag(String label) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(color: AppColors.knuRed.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
    child: Text(label.toUpperCase(), style: const TextStyle(color: AppColors.knuRed, fontSize: 11, fontWeight: FontWeight.bold)),
  );

  void _showLoginRequest(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text("Log in is required."), action: SnackBarAction(label: "Login", onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen())))));
  }
}

extension PostExtension on Post {
  Post copyWithLikes(int newLikes) => Post(id: id, title: title, content: content, author: author, createdAt: createdAt, category: category, likes: newLikes, comments: comments);
  Post copyWithComments(int newComments) => Post(id: id, title: title, content: content, author: author, createdAt: createdAt, category: category, likes: likes, comments: newComments);
}