import 'package:flutter/material.dart';
import '../services/feedback_service.dart';

class FeedbackProvider with ChangeNotifier {
  final FeedbackService _service = FeedbackService();

  List<Map<String, dynamic>> _feedbacks = [];
  bool _isLoading = false;

  List<Map<String, dynamic>> get feedbacks => _feedbacks;
  bool get isLoading => _isLoading;

  /// 모든 피드백을 서버에서 불러옵니다.
  Future<void> fetchAllFeedbacks() async {
    _isLoading = true;
    notifyListeners();

    try {
      _feedbacks = await _service.getAllFeedbacks();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 특정 피드백을 삭제합니다.
  Future<void> removeFeedback(String id) async {
    try {
      await _service.deleteFeedback(id);
      _feedbacks.removeWhere((f) => f['id'] == id);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
}