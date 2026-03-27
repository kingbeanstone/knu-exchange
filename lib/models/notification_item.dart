import 'package:cloud_firestore/cloud_firestore.dart';

enum NotificationType { comment, like, system }

class NotificationItem {
  final String id;
  final String targetUserId;    // 알림을 받을 사용자 ID
  final String senderId;        // 알림을 발생시킨 사용자 ID (익명일 경우 'Anonymous')
  final String senderName;      // 알림을 발생시킨 사용자 이름
  final String postId;          // 관련 게시글 ID
  final String postTitle;       // 관련 게시글 제목 (알림창 노출용)
  final String message;         // 알림 본문
  final NotificationType type;  // 알림 유형
  final DateTime createdAt;
  final bool isRead;            // 읽음 여부

  NotificationItem({
    required this.id,
    required this.targetUserId,
    required this.senderId,
    required this.senderName,
    required this.postId,
    required this.postTitle,
    required this.message,
    required this.type,
    required this.createdAt,
    this.isRead = false,
  });

  factory NotificationItem.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return NotificationItem(
      id: doc.id,
      targetUserId: data['targetUserId'] ?? '',
      senderId: data['senderId'] ?? '',
      senderName: data['senderName'] ?? '',
      postId: data['postId'] ?? '',
      postTitle: data['postTitle'] ?? '',
      message: data['message'] ?? '',
      type: NotificationType.values.firstWhere(
            (e) => e.toString() == data['type'],
        orElse: () => NotificationType.comment,
      ),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRead: data['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'targetUserId': targetUserId,
      'senderId': senderId,
      'senderName': senderName,
      'postId': postId,
      'postTitle': postTitle,
      'message': message,
      'type': type.toString(),
      'createdAt': Timestamp.fromDate(createdAt),
      'isRead': isRead,
    };
  }
}