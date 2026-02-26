import 'package:cloud_firestore/cloud_firestore.dart';

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
  final List<String> imageUrls; // [추가] 이미지 URL 리스트

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
    this.imageUrls = const [], // [추가] 기본값 빈 리스트
  });

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
      // [추가] 리스트 타입 캐스팅 처리
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
    );
  }

  // [참고] Firestore 저장 시 Map 변환 로직은 CommunityService에서 직접 수행하거나 여기에 작성 가능
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'content': content,
      'author': author,
      'authorId': authorId,
      'authorName': authorName,
      'createdAt': Timestamp.fromDate(createdAt),
      'category': category.toString(),
      'likes': likes,
      'comments': comments,
      'isAnonymous': isAnonymous,
      'imageUrls': imageUrls, // [추가]
    };
  }
}