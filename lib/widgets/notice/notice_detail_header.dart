import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/app_colors.dart';

class NoticeDetailHeader extends StatelessWidget {
  final String title;
  final Timestamp createdAt;

  const NoticeDetailHeader({
    super.key,
    required this.title,
    required this.createdAt,
  });

  String _formatDate(Timestamp timestamp) {
    final date = timestamp.toDate();
    return "${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 공식 공지 배지
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.knuRed.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              "OFFICIAL NOTICE",
              style: TextStyle(
                color: AppColors.knuRed,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // 제목
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.darkGrey,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),
          // 작성일
          Row(
            children: [
              const Icon(Icons.access_time, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                _formatDate(createdAt),
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}