import 'package:flutter/material.dart';
import '../../../models/comment.dart';
import '../../../utils/app_colors.dart';
import 'comment_actions.dart';

class CommentItem extends StatelessWidget {
  final String postId;
  final Comment comment;
  final bool isMyComment;
  final VoidCallback onDelete;

  const CommentItem({
    super.key,
    required this.postId,
    required this.comment,
    required this.isMyComment,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // 대댓글 여부 확인
    final bool isReply = comment.parentId != null;

    return Padding(
      padding: EdgeInsets.only(
        top: 12,
        bottom: 12,
        left: isReply ? 40 : 0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 대댓글 화살표 아이콘
          if (isReply)
            const Padding(
              padding: EdgeInsets.only(top: 8, right: 8),
              child: Icon(Icons.subdirectory_arrow_right, size: 16, color: Colors.grey),
            ),

          // 작성자 프로필 이미지
          CircleAvatar(
            radius: 14,
            backgroundColor: AppColors.lightGrey,
            child: Icon(Icons.person, color: Colors.grey[400], size: 16),
          ),
          const SizedBox(width: 12),

          // 메인 콘텐츠 영역
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 2),
                _buildTimestamp(),
                const SizedBox(height: 6),
                _buildContent(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 작성자 이름 및 버튼 영역
  Widget _buildHeader() {
    return Row(
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
          _buildMyBadge(),
        ],
        const Spacer(),
        // 분리된 액션 버튼 위젯 호출
        CommentActions(
          postId: postId,
          comment: comment,
          isMyComment: isMyComment,
          onDelete: onDelete,
        ),
      ],
    );
  }

  // 작성 시간 표시
  Widget _buildTimestamp() {
    return Text(
      "${comment.createdAt.month}/${comment.createdAt.day} ${comment.createdAt.hour.toString().padLeft(2, '0')}:${comment.createdAt.minute.toString().padLeft(2, '0')}",
      style: const TextStyle(color: Colors.grey, fontSize: 11),
    );
  }

  // 댓글 본문
  Widget _buildContent() {
    return Text(
      comment.content,
      style: const TextStyle(
        fontSize: 15,
        height: 1.5,
        color: Colors.black87,
      ),
    );
  }

  // "나" 표시 배지
  Widget _buildMyBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.knuRed.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Text(
        "ME",
        style: TextStyle(color: AppColors.knuRed, fontSize: 8, fontWeight: FontWeight.bold),
      ),
    );
  }
}