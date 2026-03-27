import 'dart:async';
import 'package:flutter/material.dart';
import '../models/notification_item.dart';
import '../services/notification_service.dart';

class NotificationProvider with ChangeNotifier {
  final NotificationService _service = NotificationService();

  List<NotificationItem> _notifications = [];
  StreamSubscription? _subscription;
  int _unreadCount = 0;

  List<NotificationItem> get notifications => _notifications;
  int get unreadCount => _unreadCount;

  // [시작] 특정 사용자의 알림 스트림 구독
  void initNotifications(String userId) {
    _subscription?.cancel();
    _subscription = _service.getNotificationsStream(userId).listen((items) {
      _notifications = items;
      _unreadCount = items.where((n) => !n.isRead).length;
      notifyListeners();
    });
  }

  // [종료] 구독 해제 (로그아웃 시 호출)
  void disposeNotifications() {
    _subscription?.cancel();
    _notifications = [];
    _unreadCount = 0;
    notifyListeners();
  }

  // 알림 읽음 처리
  Future<void> markAsRead(String userId, String notificationId) async {
    await _service.markAsRead(userId, notificationId);
  }

  // 모든 알림 읽음 처리
  Future<void> markAllAsRead(String userId) async {
    await _service.markAllAsRead(userId);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}