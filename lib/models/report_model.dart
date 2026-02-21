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

  // [수정] Firestore 데이터를 Report 객체로 변환하는 생성자 추가
  factory Report.fromFirestore(String id, Map<String, dynamic> data) {
    return Report(
      id: id,
      targetId: data['targetId'] ?? '',
      targetType: data['targetType'] ?? 'post',
      reporterId: data['reporterId'] ?? '',
      reason: data['reason'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

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