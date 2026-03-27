import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification_item.dart';

class NotificationService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _appId = 'knu-exchange-app';

  // 알림 컬렉션 경로: /artifacts/{appId}/users/{userId}/notifications
  CollectionReference _notifRef(String userId) =>
      _db.collection('artifacts').doc(_appId).collection('users').doc(userId).collection('notifications');

  // [생성] 새 알림 보내기
  Future<void> sendNotification(NotificationItem notification) async {
    // 본인이 본인 게시글에 댓글을 단 경우에는 알림을 생성하지 않음
    if (notification.targetUserId == notification.senderId) return;

    await _notifRef(notification.targetUserId).add(notification.toFirestore());
  }

  // [조회] 특정 사용자의 알림 목록 스트림 (실시간 업데이트용)
  Stream<List<NotificationItem>> getNotificationsStream(String userId) {
    return _notifRef(userId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => NotificationItem.fromFirestore(doc)).toList());
  }

  // [수정] 알림 읽음 처리
  Future<void> markAsRead(String userId, String notificationId) async {
    await _notifRef(userId).doc(notificationId).update({'isRead': true});
  }

  // [수정] 모든 알림 읽음 처리
  Future<void> markAllAsRead(String userId) async {
    final snapshot = await _notifRef(userId).where('isRead', isEqualTo: false).get();
    final batch = _db.batch();
    for (var doc in snapshot.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }
}