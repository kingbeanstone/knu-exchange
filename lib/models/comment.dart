import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String id;
  final String author;
  final String authorId;
  final String content;
  final DateTime createdAt;
  final bool isAnonymous;
  final String? parentId;
  final String? replyToName;
  final List<String> likes; // [추가] 좋아요를 누른 사용자 ID 리스트

  Comment({
    required this.id,
    required this.author,
    required this.authorId,
    required this.content,
    required this.createdAt,
    this.isAnonymous = false,
    this.parentId,
    this.replyToName,
    this.likes = const [], // [추가] 기본값 빈 리스트
  });

  factory Comment.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Comment(
      id: doc.id,
      author: data['author'] ?? 'Anonymous',
      authorId: data['authorId'] ?? '',
      content: data['content'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isAnonymous: data['isAnonymous'] ?? false,
      parentId: data['parentId'],
      replyToName: data['replyToName'],
      // [추가] likes 필드 파싱 (리스트 타입 캐스팅)
      likes: List<String>.from(data['likes'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'author': author,
      'authorId': authorId,
      'content': content,
      'createdAt': FieldValue.serverTimestamp(),
      'isAnonymous': isAnonymous,
      'parentId': parentId,
      'replyToName': replyToName,
      'likes': likes, // [추가]
    };
  }
}