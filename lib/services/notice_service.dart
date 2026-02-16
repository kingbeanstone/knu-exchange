import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notice.dart';

class NoticeService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 앱 ID 설정 (환경 변수가 없을 경우 기본값 사용)
  final String _appId = 'default-app-id';

  // 공지사항 목록 가져오기 (규칙 1에 따른 공용 데이터 경로 사용)
  Future<List<Notice>> getNotices() async {
    try {
      // 규칙 2: 복합 쿼리 대신 단순 쿼리 후 메모리에서 정렬
      final snapshot = await _db
          .collection('artifacts')
          .doc(_appId)
          .collection('public')
          .doc('data')
          .collection('notices')
          .get();

      final notices = snapshot.docs.map((doc) => Notice.fromFirestore(doc)).toList();

      // 최신순 정렬
      notices.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return notices;
    } catch (e) {
      print('공지사항 로드 중 오류 발생: $e');
      return [];
    }
  }
}