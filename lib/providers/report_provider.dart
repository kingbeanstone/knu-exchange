import 'package:flutter/material.dart';
import '../models/report_model.dart';
import '../services/report_service.dart';

class ReportProvider with ChangeNotifier {
  final ReportService _service = ReportService();
  bool _isSubmitting = false;

  bool get isSubmitting => _isSubmitting;

  Future<void> reportContent({
    required String targetId,
    required String targetType,
    required String reporterId,
    required String reason,
  }) async {
    _isSubmitting = true;
    notifyListeners();

    try {
      final report = Report(
        id: '', // Firestore에서 자동 생성
        targetId: targetId,
        targetType: targetType,
        reporterId: reporterId,
        reason: reason,
        createdAt: DateTime.now(),
      );
      await _service.submitReport(report);
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }
}