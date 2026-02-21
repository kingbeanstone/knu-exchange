import 'package:flutter/material.dart';
import '../models/report_model.dart';
import '../services/report_service.dart';

class ReportProvider with ChangeNotifier {
  final ReportService _service = ReportService();

  List<Report> _reports = [];
  bool _isSubmitting = false;
  bool _isLoading = false;

  List<Report> get reports => _reports;
  bool get isSubmitting => _isSubmitting;
  bool get isLoading => _isLoading;

  // [신규] 관리자용: 전체 신고 목록 조회 및 상태 업데이트
  Future<void> fetchAllReports() async {
    _isLoading = true;
    notifyListeners();
    try {
      _reports = await _service.getAllReports();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // [신규] 관리자용: 처리 완료된 신고 내역 목록에서 제거
  Future<void> removeReportRecord(String reportId) async {
    try {
      await _service.deleteReport(reportId);
      _reports.removeWhere((r) => r.id == reportId);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  // [기존] 일반 사용자용: 신고 제출
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
        id: '', // Firestore 자동 생성
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