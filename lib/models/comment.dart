import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String id;
  final String author;
  final String authorId;
  final String content;
  final DateTime createdAt;

  Comment({
    required this.id,
    required this.author,
    required this.authorId,
    required this.content,
    required this.createdAt,
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
    );
  }

  // 모델을 Firestore 데이터로 변환
  Map<String, dynamic> toFirestore() {
    return {
      'author': author,
      'authorId': authorId,
      'content': content,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}