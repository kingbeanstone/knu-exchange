import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String id;
  final String author;
  final String authorId;
  final String content;
  final DateTime createdAt;
  final bool isAnonymous;
  final String? parentId;     // [추가] 부모 댓글 ID (대댓글인 경우)
  final String? replyToName;  // [추가] 답글 대상자 이름 (UI 표시용)

  Comment({
    required this.id,
    required this.author,
    required this.authorId,
    required this.content,
    required this.createdAt,
    this.isAnonymous = false,
    this.parentId,
    this.replyToName,
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
    };
  }
}