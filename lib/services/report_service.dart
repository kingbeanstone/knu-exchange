import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/report_model.dart';

class ReportService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _appId = 'knu-exchange-app';

  // 신고 데이터 컬렉션 참조 경로
  CollectionReference get _reportsRef => _db
      .collection('artifacts')
      .doc(_appId)
      .collection('public')
      .doc('data')
      .collection('reports');

  // 신고 제출
  Future<void> submitReport(Report report) async {
    try {
      await _reportsRef.add(report.toFirestore());
    } catch (e) {
      print('Report submission error: $e');
      rethrow;
    }
  }

  // [오류 수정] Report.fromFirestore를 호출하여 리스트 반환
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

  // 조치 완료된 신고 내역 삭제
  Future<void> deleteReport(String reportId) async {
    try {
      await _reportsRef.doc(reportId).delete();
    } catch (e) {
      print('Error deleting report: $e');
      rethrow;
    }
  }
}