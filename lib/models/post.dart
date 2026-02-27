import 'package:cloud_firestore/cloud_firestore.dart';

// [수정] 'food' 카테고리 추가
enum PostCategory { hot, question, tip, lounge, food }

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
  final List<String> imageUrls;

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
    this.imageUrls = const [],
  });

  String get categoryLabel {
    switch (category) {
      case PostCategory.hot: return 'Hot';
      case PostCategory.question: return 'Question';
      case PostCategory.tip: return 'Tip';
      case PostCategory.lounge: return 'Lounge';
      case PostCategory.food: return 'Food'; // [추가]
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
            (e) => e.toString().split('.').last == data['category'],
        orElse: () => PostCategory.lounge,
      ),
      likes: data['likes'] ?? 0,
      comments: data['comments'] ?? 0,
      isAnonymous: data['isAnonymous'] ?? false,
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'content': content,
      'author': author,
      'authorId': authorId,
      'authorName': authorName,
      'createdAt': Timestamp.fromDate(createdAt),
      'category': category.toString().split('.').last, // 저장 시 문자열 값만 저장
      'likes': likes,
      'comments': comments,
      'isAnonymous': isAnonymous,
      'imageUrls': imageUrls,
    };
  }
}