import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/report_model.dart';

class ReportService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _appId = 'knu-exchange-app';

  // 신고 데이터를 Firestore에 저장합니다.
  Future<void> submitReport(Report report) async {
    try {
      await _db
          .collection('artifacts')
          .doc(_appId)
          .collection('public')
          .doc('data')
          .collection('reports')
          .add(report.toFirestore());
    } catch (e) {
      print('Report submission error: $e');
      rethrow;
    }
  }
}