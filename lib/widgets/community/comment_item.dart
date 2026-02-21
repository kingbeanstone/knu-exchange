import 'package:flutter/material.dart';
import '../../../models/comment.dart';
import '../../../utils/app_colors.dart';

class CommentItem extends StatelessWidget {
  final Comment comment;
  final bool isMyComment;
  final VoidCallback onDelete;

  const CommentItem({
    super.key,
    required this.comment,
    required this.isMyComment,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    comment.author,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "${comment.createdAt.month}/${comment.createdAt.day}",
                    style: const TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                comment.content,
                style: const TextStyle(fontSize: 14, height: 1.4),
              ),
            ],
          ),
        ),
        if (isMyComment)
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 20, color: Colors.grey),
            onPressed: onDelete,
            visualDensity: VisualDensity.compact,
          ),
      ],
    );
  }
}