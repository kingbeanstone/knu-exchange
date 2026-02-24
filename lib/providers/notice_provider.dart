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

  /// 🔥 Firestore 실시간 구독 시작
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

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}