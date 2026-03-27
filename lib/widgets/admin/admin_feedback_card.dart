import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../utils/app_colors.dart';

class AdminFeedbackCard extends StatelessWidget {
  final Map<String, dynamic> feedback;
  final VoidCallback onDelete;

  const AdminFeedbackCard({
    super.key,
    required this.feedback,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final DateTime date = (feedback['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
    final String formattedDate = DateFormat('yyyy.MM.dd HH:mm').format(date);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      feedback['userEmail'] ?? 'Unknown User',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      formattedDate,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.grey, size: 20),
                onPressed: onDelete,
              ),
            ],
          ),
          const Divider(height: 24),
          Text(
            feedback['content'] ?? '',
            style: const TextStyle(fontSize: 15, height: 1.5, color: AppColors.darkGrey),
          ),
        ],
      ),
    );
  }
}