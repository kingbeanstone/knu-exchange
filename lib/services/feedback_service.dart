import 'package:cloud_firestore/cloud_firestore.dart';

class FeedbackService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _appId = 'knu-exchange-app';

  /// 사용자가 작성한 피드백을 Firestore에 저장합니다.
  Future<void> submitFeedback({
    required String content,
    required String userId,
    required String userEmail,
  }) async {
    try {
      await _db
          .collection('artifacts')
          .doc(_appId)
          .collection('public')
          .doc('data')
          .collection('feedbacks')
          .add({
        'content': content,
        'userId': userId,
        'userEmail': userEmail,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }

  /// [추가] 관리자용: 모든 피드백 목록을 최신순으로 가져옵니다.
  Future<List<Map<String, dynamic>>> getAllFeedbacks() async {
    try {
      final snapshot = await _db
          .collection('artifacts')
          .doc(_appId)
          .collection('public')
          .doc('data')
          .collection('feedbacks')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Error fetching feedbacks: $e');
      return [];
    }
  }

  /// [추가] 피드백 삭제 (처리 완료 후 기록 삭제용)
  Future<void> deleteFeedback(String feedbackId) async {
    await _db
        .collection('artifacts')
        .doc(_appId)
        .collection('public')
        .doc('data')
        .collection('feedbacks')
        .doc(feedbackId)
        .delete();
  }
}