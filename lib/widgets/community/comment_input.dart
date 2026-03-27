import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/comment_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../utils/app_colors.dart';
import '../../screens/auth/login_screen.dart';

class CommentInput extends StatefulWidget {
  final String postId;
  const CommentInput({super.key, required this.postId});

  @override
  State<CommentInput> createState() => _CommentInputState();
}

class _CommentInputState extends State<CommentInput> {
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;
  bool _isAnonymous = true;

  Future<void> _submitComment() async {
    if (_isSubmitting) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final commentProvider = Provider.of<CommentProvider>(context, listen: false);

    if (!auth.isAuthenticated) {
      _showLoginRequest();
      return;
    }

    final content = _commentController.text.trim();
    if (content.isEmpty) return;

    setState(() => _isSubmitting = true);

    try {
      await commentProvider.addComment(
        widget.postId,
        auth.user?.displayName ?? "User",
        auth.user!.uid,
        content,
        isAnonymous: _isAnonymous,
      );
      _commentController.clear();
      if (mounted) FocusScope.of(context).unfocus();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to post: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showLoginRequest() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text("Login is required to comment."),
      action: SnackBarAction(
          label: "Login",
          onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen())
          )
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final commentProvider = context.watch<CommentProvider>();
    final replyingTo = commentProvider.replyingTo;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -2),
            blurRadius: 10,
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (replyingTo != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.reply, size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Replying to ${replyingTo.author}...",
                          style: const TextStyle(fontSize: 12, color: AppColors.darkGrey),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => commentProvider.setReplyingTo(null),
                        child: const Icon(Icons.close, size: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                ),

              Row(
                children: [
                  SizedBox(
                    height: 24,
                    width: 24,
                    child: Checkbox(
                      value: _isAnonymous,
                      activeColor: AppColors.knuRed,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      onChanged: (val) => setState(() => _isAnonymous = val ?? false),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "Post Anonymously",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: TextField(
                        controller: _commentController,
                        enabled: !_isSubmitting,
                        decoration: InputDecoration(
                          hintText: replyingTo != null ? "Write a reply..." : "Add a comment...",
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        maxLines: 5,
                        minLines: 1,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _isSubmitting
                      ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.knuRed),
                    ),
                  )
                      : IconButton(
                    onPressed: _submitComment,
                    icon: const Icon(Icons.send_rounded, color: AppColors.knuRed),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}