import 'dart:async';
import 'package:flutter/material.dart';
import '../models/notice.dart';
import '../services/notice_service.dart';

class NoticeProvider extends ChangeNotifier {
  final NoticeService _service = NoticeService();

  List<Notice> _notices = [];
  bool _isLoading = false;
  StreamSubscription<List<Notice>>? _subscription;

  List<Notice> get notices => _notices;
  bool get isLoading => _isLoading;

  NoticeProvider() {
    _startListening();
  }

  /// 🔥 Firestore 실시간 구독 시작 (기존 코드 기능 유지)
  void _startListening() {
    _isLoading = true;
    notifyListeners();

    _subscription?.cancel();
    _subscription = _service.streamNotices().listen(
          (notices) {
        _notices = notices;
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        debugPrint("Notice stream error: $error");
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  /// 공지사항 작성 로직 (알림 연동을 위해 Root의 'notices' 컬렉션 사용)
  Future<void> createNotice(String title, String content) async {
    try {
      await _service.addNotice(title, content);
      // 알림은 Cloud Functions(index.js)에서 'notices' 토픽으로 자동 발송됩니다.
    } catch (e) {
      debugPrint("Create notice provider error: $e");
      rethrow;
    }
  }

  /// 공지사항 삭제 로직
  Future<void> removeNotice(String noticeId) async {
    try {
      await _service.deleteNotice(noticeId);
    } catch (e) {
      debugPrint("Remove notice provider error: $e");
      rethrow;
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}