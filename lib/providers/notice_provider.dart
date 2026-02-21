import 'package:flutter/material.dart';
import '../models/notice.dart';
import '../services/notice_service.dart';

class NoticeProvider with ChangeNotifier {
  final NoticeService _service = NoticeService();

  List<Notice> _notices = [];
  bool _isLoading = false;

  List<Notice> get notices => _notices;
  bool get isLoading => _isLoading;

  // 공지사항 새로고침
  Future<void> refreshNotices() async {
    _isLoading = true;
    notifyListeners();

    try {
      _notices = await _service.fetchRemoteNotices();
    } catch (e) {
      debugPrint("공지사항 업데이트 오류: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}