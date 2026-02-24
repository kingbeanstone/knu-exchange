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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 댓글 작성자 아이콘
          CircleAvatar(
            radius: 14,
            backgroundColor: AppColors.lightGrey,
            child: Icon(Icons.person, color: Colors.grey[400], size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          comment.author,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: AppColors.darkGrey,
                          ),
                        ),
                        if (isMyComment) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.knuRed.withValues(alpha: 0.5)),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              "ME",
                              style: TextStyle(color: AppColors.knuRed, fontSize: 8, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      "${comment.createdAt.month}/${comment.createdAt.day} ${comment.createdAt.hour.toString().padLeft(2, '0')}:${comment.createdAt.minute.toString().padLeft(2, '0')}",
                      style: const TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  comment.content,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          if (isMyComment)
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 18, color: Colors.grey),
              onPressed: onDelete,
              constraints: const BoxConstraints(),
              padding: const EdgeInsets.only(left: 8),
              visualDensity: VisualDensity.compact,
            ),
        ],
      ),
    );
  }
}