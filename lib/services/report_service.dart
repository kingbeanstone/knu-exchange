import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/report_model.dart';

class ReportService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _appId = 'knu-exchange-app';

  // 신고 데이터 컬렉션 참조 경로 (RULE 1 준수)
  CollectionReference get _reportsRef => _db
      .collection('artifacts')
      .doc(_appId)
      .collection('public')
      .doc('data')
      .collection('reports');

  /// [추가] 자동 삭제 로직을 위한 원시 데이터 제출 메서드
  /// Cloud Functions 트리거가 인식할 수 있도록 Map 형태로 데이터를 Firestore에 직접 추가합니다.
  Future<void> submitRawReport(Map<String, dynamic> reportData) async {
    try {
      await _reportsRef.add(reportData);
    } catch (e) {
      print('Raw report submission error: $e');
      rethrow;
    }
  }

  /// 기존 방식: 신고 모델을 사용하여 제출
  Future<void> submitReport(Report report) async {
    try {
      await _reportsRef.add(report.toFirestore());
    } catch (e) {
      print('Report submission error: $e');
      rethrow;
    }
  }

  /// 관리자용: 모든 신고 목록 조회
  Future<List<Report>> getAllReports() async {
    try {
      final snapshot = await _reportsRef.orderBy('createdAt', descending: true).get();
      return snapshot.docs
          .map((doc) => Report.fromFirestore(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching all reports: $e');
      return [];
    }
  }

  /// 조치 완료된 신고 내역 삭제
  Future<void> deleteReport(String reportId) async {
    try {
      await _reportsRef.doc(reportId).delete();
    } catch (e) {
      print('Error deleting report: $e');
      rethrow;
    }
  }
}