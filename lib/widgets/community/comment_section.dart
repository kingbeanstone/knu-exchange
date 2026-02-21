import 'package:flutter/material.dart';
// export 문은 모든 선언(class 등)보다 위에 위치해야 합니다.
export 'comment_input.dart';
import 'comment_list.dart';

/// 댓글 섹션 통합 위젯
/// 상세 페이지 스크롤 내부에서 목록을 보여주는 역할을 합니다.
class CommentSection extends StatelessWidget {
  final String postId;
  const CommentSection({super.key, required this.postId});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          "Comments",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        CommentList(postId: postId),
        const SizedBox(height: 20),
      ],
    );
  }
}