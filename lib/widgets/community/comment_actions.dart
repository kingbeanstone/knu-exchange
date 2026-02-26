import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/comment.dart';
import '../../../providers/comment_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../utils/app_colors.dart';
import '../report_dialog.dart';

class CommentActions extends StatelessWidget {
  final String postId;
  final Comment comment;
  final bool isMyComment;
  final VoidCallback onDelete;

  const CommentActions({
    super.key,
    required this.postId,
    required this.comment,
    required this.isMyComment,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final userId = authProvider.user?.uid;
    final bool isLiked = userId != null && comment.likes.contains(userId);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 1. 답글 버튼 (최상위 댓글에만 노출)
        if (comment.parentId == null)
          _buildIconButton(
            icon: Icons.reply_outlined,
            onPressed: () => context.read<CommentProvider>().setReplyingTo(comment),
            tooltip: 'Reply',
          ),

        // 2. 좋아요 버튼 및 카운트
        _buildLikeSection(context, authProvider, isLiked),

        // 3. 더보기 메뉴 (신고/삭제)
        _buildMoreMenu(context),
      ],
    );
  }

  // 아이콘 버튼 공통 스타일
  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onPressed,
    Color color = Colors.grey,
    String? tooltip,
  }) {
    return IconButton(
      icon: Icon(icon, size: 18, color: color),
      onPressed: onPressed,
      constraints: const BoxConstraints(),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      visualDensity: VisualDensity.compact,
      tooltip: tooltip,
    );
  }

  // 좋아요 영역
  Widget _buildLikeSection(BuildContext context, AuthProvider auth, bool isLiked) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildIconButton(
          icon: isLiked ? Icons.favorite : Icons.favorite_border_rounded,
          color: isLiked ? AppColors.knuRed : Colors.grey,
          onPressed: () async {
            if (!auth.isAuthenticated) return;
            await context.read<CommentProvider>().toggleCommentLike(
              postId,
              comment.id,
              auth.user!.uid,
            );
          },
        ),
        if (comment.likes.isNotEmpty)
          Text(
            '${comment.likes.length}',
            style: TextStyle(
              fontSize: 11,
              color: isLiked ? AppColors.knuRed : Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
        const SizedBox(width: 4),
      ],
    );
  }

  // 더보기 메뉴
  Widget _buildMoreMenu(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert_rounded, size: 18, color: Colors.grey),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      onSelected: (value) {
        if (value == 'report') {
          _showReportDialog(context);
        } else if (value == 'delete') {
          onDelete();
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'report',
          child: Row(
            children: [
              Icon(Icons.report_problem_outlined, size: 18, color: Colors.redAccent),
              SizedBox(width: 8),
              Text('Report', style: TextStyle(fontSize: 14)),
            ],
          ),
        ),
        if (isMyComment)
          const PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                Icon(Icons.delete_outline_rounded, size: 18, color: Colors.grey),
                SizedBox(width: 8),
                Text('Delete', style: TextStyle(fontSize: 14)),
              ],
            ),
          ),
      ],
    );
  }

  void _showReportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ReportDialog(
        targetId: comment.id,
        targetType: 'comment',
      ),
    );
  }
}