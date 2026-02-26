import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/comment.dart';
import '../../../providers/comment_provider.dart';
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
    // 대댓글인 경우 왼쪽 여백을 줍니다.
    final bool isReply = comment.parentId != null;

    return Padding(
      padding: EdgeInsets.only(
        top: 12,
        bottom: 12,
        left: isReply ? 40 : 0, // 대댓글 여백 적용
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 대댓글일 경우 꺽쇠 아이콘 표시
          if (isReply)
            const Padding(
              padding: EdgeInsets.only(top: 8, right: 8),
              child: Icon(Icons.subdirectory_arrow_right, size: 16, color: Colors.grey),
            ),

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
                          _buildBadge("ME"),
                        ],
                        // [추가] 누구에게 답글을 남겼는지 표시
                        if (comment.replyToName != null) ...[
                          const SizedBox(width: 6),
                          const Icon(Icons.play_arrow, size: 10, color: Colors.grey),
                          const SizedBox(width: 6),
                          Text(
                            comment.replyToName!,
                            style: const TextStyle(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.w600),
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
                const SizedBox(height: 8),

                // [추가] 답글 달기 버튼
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        // 해당 댓글을 답글 대상으로 설정
                        context.read<CommentProvider>().setReplyingTo(comment);
                      },
                      child: const Text(
                        "Reply",
                        style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 16),
                    if (isMyComment)
                      GestureDetector(
                        onTap: onDelete,
                        child: const Text(
                          "Delete",
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.knuRed.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: const TextStyle(color: AppColors.knuRed, fontSize: 8, fontWeight: FontWeight.bold),
      ),
    );
  }
}