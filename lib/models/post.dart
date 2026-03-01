import 'package:cloud_firestore/cloud_firestore.dart';

// [참고] 데이터베이스 호환성을 위해 enum 값 이름인 'lounge'는 유지합니다.
enum PostCategory { hot, question, tip, lounge, food }

// [추가] 카테고리별 표시 이름을 관리하는 확장 기능
extension PostCategoryExtension on PostCategory {
  String get label {
    switch (this) {
      case PostCategory.hot: return 'Hot';
      case PostCategory.question: return 'Question';
      case PostCategory.tip: return 'Tip';
      case PostCategory.lounge: return 'General'; // Lounge 대신 General 반환
      case PostCategory.food: return 'Food';
    }
  }
}

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

  // [수정] 위에서 정의한 label 확장 기능을 사용하여 중복 코드를 제거합니다.
  String get categoryLabel => category.label;

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
      'category': category.toString().split('.').last,
      'likes': likes,
      'comments': comments,
      'isAnonymous': isAnonymous,
      'imageUrls': imageUrls,
    };
  }
}