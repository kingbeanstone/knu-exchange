import 'package:cloud_firestore/cloud_firestore.dart';

enum PostCategory { question, tip, market, free }

class Post {
  final String id;
  final String title;
  final String content;
  final String author;     // 화면 표시용
  final String authorId;   // 고유 UID
  final String authorName;
  final DateTime createdAt;
  final PostCategory category;
  final int likes;
  final int comments;
  final bool isAnonymous;  // [추가] 익명 여부 플래그

  Post({
    required this.id,
    required this.title,
    required this.content,
    required this.author,
    required this.authorId,
    required this.authorName,
    required this.createdAt,
    required this.category,
    this.likes = 0,
    this.comments = 0,
    this.isAnonymous = false, // [추가] 기본값은 false
  });

  String get categoryLabel {
    switch (category) {
      case PostCategory.question: return 'Question';
      case PostCategory.tip: return 'Tip';
      case PostCategory.market: return 'Market';
      case PostCategory.free: return 'Free';
    }
  }

  factory Post.fromFirestore(String id, Map<String, dynamic> data) {
    return Post(
      id: id,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      author: data['author'] ?? 'Anonymous',
      authorId: data['authorId'] ?? '',
      authorName: data['authorName'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      category: PostCategory.values.firstWhere(
            (e) => e.toString() == data['category'],
        orElse: () => PostCategory.free,
      ),
      likes: data['likes'] ?? 0,
      comments: data['comments'] ?? 0,
      isAnonymous: data['isAnonymous'] ?? false, // [추가] 저장된 값 로드
    );
  }
}