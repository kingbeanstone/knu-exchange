import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/post.dart';
import '../../providers/auth_provider.dart';
import '../../providers/like_provider.dart';
import '../../utils/app_colors.dart';
import '../../screens/settings/login_screen.dart';

class PostActionBar extends StatefulWidget {
  final Post post;
  const PostActionBar({super.key, required this.post});

  @override
  State<PostActionBar> createState() => _PostActionBarState();
}

class _PostActionBarState extends State<PostActionBar> {
  bool _isLiked = false;
  late int _likeCount;

  @override
  void initState() {
    super.initState();
    _likeCount = widget.post.likes;
    _checkInitialLike();
  }

  Future<void> _checkInitialLike() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.isAuthenticated) {
      final liked = await Provider.of<LikeProvider>(context, listen: false)
          .getIsLikedOnce(widget.post.id, auth.user!.uid);
      if (mounted) setState(() => _isLiked = liked);
    }
  }

  Future<void> _handleLike() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final likeProvider = Provider.of<LikeProvider>(context, listen: false);

    if (!auth.isAuthenticated) {
      _showLoginRequest();
      return;
    }

    setState(() {
      _isLiked = !_isLiked;
      _likeCount += _isLiked ? 1 : -1;
    });

    try {
      await likeProvider.toggleLike(widget.post.id, auth.user!.uid);
    } catch (e) {
      setState(() {
        _isLiked = !_isLiked;
        _likeCount += _isLiked ? 1 : -1;
      });
    }
  }

  void _showLoginRequest() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text("Log in is required."),
      action: SnackBarAction(label: "Login", onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()))),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Colors.grey.shade200))),
        child: Row(children: [
          InkWell(
            onTap: _handleLike,
            child: Row(children: [
              Icon(_isLiked ? Icons.favorite : Icons.favorite_border, color: AppColors.knuRed, size: 24),
              const SizedBox(width: 8),
              Text('$_likeCount', style: const TextStyle(color: AppColors.knuRed, fontWeight: FontWeight.bold, fontSize: 16)),
            ]),
          ),
          const SizedBox(width: 24),
          Icon(Icons.chat_bubble_outline, color: Colors.grey[600], size: 22),
          const SizedBox(width: 8),
          Text('${widget.post.comments}', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
          const Spacer(),
          IconButton(onPressed: () {}, icon: const Icon(Icons.share_outlined, color: Colors.grey)),
        ]),
      ),
    );
  }
}