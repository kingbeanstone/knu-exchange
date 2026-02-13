import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/comment_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_colors.dart';
import '../../screens/settings/login_screen.dart';

class CommentInput extends StatefulWidget {
  final String postId;
  const CommentInput({super.key, required this.postId});

  @override
  State<CommentInput> createState() => _CommentInputState();
}

class _CommentInputState extends State<CommentInput> {
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;

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
      );
      _commentController.clear();
      if (mounted) FocusScope.of(context).unfocus();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to post comment: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showLoginRequest() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text("Log in is required."),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -2),
            blurRadius: 5,
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _commentController,
                  enabled: !_isSubmitting,
                  decoration: const InputDecoration(
                    hintText: "Add a comment...",
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                  ),
                  maxLines: null,
                ),
              ),
            ),
            const SizedBox(width: 8),
            _isSubmitting
                ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                : IconButton(
              onPressed: _submitComment,
              icon: const Icon(Icons.send_rounded, color: AppColors.knuRed),
            ),
          ],
        ),
      ),
    );
  }
}