import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/comment_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../utils/app_colors.dart';
import 'comment_item.dart';

class CommentList extends StatelessWidget {
  final String postId;

  const CommentList({super.key, required this.postId});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CommentProvider>(context);
    final auth = Provider.of<AuthProvider>(context, listen: false);

    if (provider.isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (provider.comments.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Text("No comments yet.", style: TextStyle(color: Colors.grey)),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: provider.comments.length,
      separatorBuilder: (_, __) => const Divider(height: 24),
      itemBuilder: (context, index) {
        final comment = provider.comments[index];
        return CommentItem(
          comment: comment,
          isMyComment: auth.user?.uid == comment.authorId,
          onDelete: () => _confirmDelete(context, provider, comment.id),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, CommentProvider provider, String commentId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Comment"),
        content: const Text("Are you sure you want to delete this comment?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await provider.removeComment(postId, commentId);
            },
            child: const Text("Delete", style: TextStyle(color: AppColors.knuRed)),
          ),
        ],
      ),
    );
  }
}