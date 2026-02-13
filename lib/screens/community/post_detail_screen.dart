import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/post.dart';
import '../../providers/community_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/like_provider.dart';
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

  @override
  void initState() {
    super.initState();
    _currentPost = widget.post;
    _initData();
  }

  Future<void> _initData() async {
    final communityProvider = Provider.of<CommunityProvider>(context, listen: false);
    final likeProvider = Provider.of<LikeProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final updatedPost = await communityProvider.getPostDetail(widget.post.id);
    if (updatedPost != null && mounted) {
      setState(() => _currentPost = updatedPost);
    }

    if (authProvider.isAuthenticated && mounted) {
      final liked = await likeProvider.getIsLikedOnce(widget.post.id, authProvider.user!.uid);
      if (mounted) {
        setState(() {
          _isLiked = liked;
          _isFetching = false;
        });
      }
    } else {
      if (mounted) setState(() => _isFetching = false);
    }
  }

  Future<void> _handleLike() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final likeProvider = Provider.of<LikeProvider>(context, listen: false);

    if (!auth.isAuthenticated) {
      _showLoginRequest(context);
      return;
    }

    // [Optimistic UI] 즉시 화면 반영
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
      // 에러 발생 시 원래 상태로 롤백
      if (mounted) {
        setState(() {
          if (_isLiked) {
            _isLiked = false;
            _currentPost = _currentPost.copyWithLikes(_currentPost.likes - 1);
          } else {
            _isLiked = true;
            _currentPost = _currentPost.copyWithLikes(_currentPost.likes + 1);
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to update like.")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Detail'),
        backgroundColor: AppColors.knuRed,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isFetching
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Padding(
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
              SelectionArea(child: Text(_currentPost.content, style: const TextStyle(fontSize: 16, height: 1.7, color: Colors.black87))),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildCategoryTag(String label) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(color: AppColors.knuRed.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
    child: Text(label.toUpperCase(), style: const TextStyle(color: AppColors.knuRed, fontSize: 11, fontWeight: FontWeight.bold)),
  );

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
        const Spacer(),
        IconButton(onPressed: () {}, icon: const Icon(Icons.share_outlined, color: Colors.grey)),
      ]),
    ),
  );

  void _showLoginRequest(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text("Log in is required to like."), action: SnackBarAction(label: "Login", onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen())))));
  }
}

extension PostExtension on Post {
  Post copyWithLikes(int newLikes) => Post(id: id, title: title, content: content, author: author, createdAt: createdAt, category: category, likes: newLikes, comments: comments);
}