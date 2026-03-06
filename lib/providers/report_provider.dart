import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  // 관리자용: 전체 신고 목록 조회
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

  // 관리자용: 처리 완료된 신고 내역 삭제
  Future<void> removeReportRecord(String reportId) async {
    try {
      await _service.deleteReport(reportId);
      _reports.removeWhere((r) => r.id == reportId);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  /// [수정] 일반 사용자용: 신고 제출 로직
  /// reportedUserId 매개변수를 필수(required)로 포함하도록 메서드 시그니처를 수정했습니다.
  Future<void> reportContent({
    required String targetId,
    required String targetType,
    required String reportedUserId, // 피신고자(작성자) ID 추가
    required String reporterId,
    required String reason,
  }) async {
    _isSubmitting = true;
    notifyListeners();

    try {
      // 서버 트리거(Cloud Functions)가 인식할 수 있도록 Map 형태로 데이터 전달
      await _service.submitRawReport({
        'targetId': targetId,
        'targetType': targetType,
        'reportedUserId': reportedUserId, // 맵에 포함
        'reporterId': reporterId,
        'reason': reason,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint("Report submit error: $e");
      rethrow;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }
}