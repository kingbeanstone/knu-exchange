import 'package:flutter/material.dart';
import '../models/notice.dart';
import '../services/notice_service.dart';

class NoticeProvider extends ChangeNotifier {
  final NoticeService _service = NoticeService();

  List<Notice> _notices = [];
  bool _isLoading = false;

  List<Notice> get notices => _notices;
  bool get isLoading => _isLoading;

  // 공지사항 데이터를 새로고침
  Future<void> fetchNotices() async {
    _isLoading = true;
    notifyListeners();

    try {
      _notices = await _service.getNotices();
    } catch (e) {
      debugPrint('NoticeProvider fetch error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}