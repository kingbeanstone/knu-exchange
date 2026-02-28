import 'package:cloud_firestore/cloud_firestore.dart';

class Notice {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;

  Notice({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
  });

  factory Notice.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Notice(
      id: doc.id,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      // [수정] 작성 직후 createdAt이 null인 상태에서도 앱이 튕기지 않도록 방어 로직 추가
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}