import 'package:cloud_firestore/cloud_firestore.dart'; // [추가] Timestamp 타입을 인식하기 위해 필요

enum PostCategory { question, tip, market, free }

class Post {
  final String id;
  final String title;
  final String content;
  final String author;     // 화면 표시용 (닉네임 또는 이메일)
  final String authorId;   // 권한 확인용 (고유 UID)
  final DateTime createdAt;
  final PostCategory category;
  final int likes;
  final int comments;

  Post({
    required this.id,
    required this.title,
    required this.content,
    required this.author,
    required this.authorId,
    required this.createdAt,
    required this.category,
    this.likes = 0,
    this.comments = 0,
  });

  String get categoryLabel {
    switch (category) {
      case PostCategory.question: return 'Question';
      case PostCategory.tip: return 'Tip';
      case PostCategory.market: return 'Market';
      case PostCategory.free: return 'Free';
    }
  }

  // 팩토리 생성자 추가하여 데이터 매핑 시 안전성 확보
  factory Post.fromFirestore(String id, Map<String, dynamic> data) {
    return Post(
      id: id,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      author: data['author'] ?? 'Anonymous',
      authorId: data['authorId'] ?? '', // DB에 없으면 빈 문자열
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      category: PostCategory.values.firstWhere(
            (e) => e.toString() == data['category'],
        orElse: () => PostCategory.free,
      ),
      likes: data['likes'] ?? 0,
      comments: data['comments'] ?? 0,
    );
  }
}