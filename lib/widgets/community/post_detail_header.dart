import 'package:flutter/material.dart';
import '../../models/post.dart';
import '../../utils/app_colors.dart';

class PostDetailHeader extends StatelessWidget {
  final Post post;

  const PostDetailHeader({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 카테고리 배지
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.knuRed.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              post.categoryLabel.toUpperCase(),
              style: const TextStyle(
                color: AppColors.knuRed,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // 제목
          Text(
            post.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              height: 1.3,
              color: AppColors.darkGrey,
            ),
          ),
          const SizedBox(height: 20),
          // 작성자 정보
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.lightGrey,
                child: Icon(Icons.person, color: Colors.grey[400], size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.isAnonymous ? "Anonymous" : post.author,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${post.createdAt.year}.${post.createdAt.month.toString().padLeft(2, '0')}.${post.createdAt.day.toString().padLeft(2, '0')}',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}