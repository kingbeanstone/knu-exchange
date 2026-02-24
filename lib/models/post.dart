import 'package:cloud_firestore/cloud_firestore.dart';

// [수정] hot 카테고리 추가
enum PostCategory { hot, question, tip, market, free }

class Post {
  final String id;
  final String title;
  final String content;
  final String author;
  final String authorId;
  final String authorName;
  final DateTime createdAt;
  final PostCategory category;
  final int likes;
  final int comments;
  final bool isAnonymous;

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
    this.isAnonymous = false,
  });

  // [수정] hot 레이블 추가
  String get categoryLabel {
    switch (category) {
      case PostCategory.hot: return 'Hot';
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
      isAnonymous: data['isAnonymous'] ?? false,
    );
  }
}