import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/comment_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../utils/app_colors.dart';
import '../../../models/comment.dart';
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

    // 계층 구조 정렬 로직
    final List<Comment> organizedComments = [];
    final Map<String?, List<Comment>> commentGroups = {};

    for (var comment in provider.comments) {
      commentGroups.putIfAbsent(comment.parentId, () => []).add(comment);
    }

    final parents = commentGroups[null] ?? [];
    for (var parent in parents) {
      organizedComments.add(parent);
      final replies = commentGroups[parent.id] ?? [];
      organizedComments.addAll(replies);
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: organizedComments.length,
      itemBuilder: (context, index) {
        final comment = organizedComments[index];
        return Column(
          children: [
            CommentItem(
              postId: postId, // [수정] postId 전달
              comment: comment,
              isMyComment: auth.user?.uid == comment.authorId,
              onDelete: () => _confirmDelete(context, provider, comment.id),
            ),
            if (index < organizedComments.length - 1)
              const Divider(height: 1, color: AppColors.lightGrey),
          ],
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