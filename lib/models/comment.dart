import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String id;
  final String author;
  final String authorId;
  final String content;
  final DateTime createdAt;
  final bool isAnonymous; // [추가] 익명 여부 필드

  Comment({
    required this.id,
    required this.author,
    required this.authorId,
    required this.content,
    required this.createdAt,
    this.isAnonymous = false, // [추가] 기본값 false
  });

  // Firestore 데이터를 모델로 변환
  factory Comment.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Comment(
      id: doc.id,
      author: data['author'] ?? 'Anonymous',
      authorId: data['authorId'] ?? '',
      content: data['content'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isAnonymous: data['isAnonymous'] ?? false, // [추가]
    );
  }

  // 모델을 Firestore 데이터로 변환
  Map<String, dynamic> toFirestore() {
    return {
      'author': author,
      'authorId': authorId,
      'content': content,
      'createdAt': FieldValue.serverTimestamp(),
      'isAnonymous': isAnonymous, // [추가]
    };
  }
}