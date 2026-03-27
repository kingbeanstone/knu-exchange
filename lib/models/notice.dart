import 'package:cloud_firestore/cloud_firestore.dart';

class Notice {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  // [수정] 단일 이미지 URL에서 리스트 형태로 변경
  final List<String> imageUrls;

  Notice({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.imageUrls,
  });

  factory Notice.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // [수정] Firestore의 'imageUrls' 필드를 리스트로 안전하게 변환
    List<String> urls = [];
    if (data['imageUrls'] != null) {
      urls = List<String>.from(data['imageUrls']);
    } else if (data['imageUrl'] != null) {
      // 기존 단일 데이터 사용자를 위한 하위 호환성 유지
      urls = [data['imageUrl'] as String];
    }

    return Notice(
      id: doc.id,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      imageUrls: urls,
    );
  }
}