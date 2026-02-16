import 'package:cloud_firestore/cloud_firestore.dart';

class Report {
  final String id;
  final String targetId;      // 신고 대상 (게시글 ID 또는 댓글 ID)
  final String targetType;    // 'post' 또는 'comment'
  final String reporterId;    // 신고자 UID
  final String reason;        // 신고 사유
  final DateTime createdAt;   // 신고 시간

  Report({
    required this.id,
    required this.targetId,
    required this.targetType,
    required this.reporterId,
    required this.reason,
    required this.createdAt,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'targetId': targetId,
      'targetType': targetType,
      'reporterId': reporterId,
      'reason': reason,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}