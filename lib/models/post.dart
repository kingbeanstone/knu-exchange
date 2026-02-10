enum PostCategory { question, tip, market, free }

class Post {
  final String id;
  final String title;
  final String content;
  final String author;
  final DateTime createdAt;
  final PostCategory category;
  final int likes;
  final int comments;

  Post({
    required this.id,
    required this.title,
    required this.content,
    required this.author,
    required this.createdAt,
    required this.category,
    this.likes = 0,
    this.comments = 0,
  });

  // 카테고리별 영문 라벨 반환
  String get categoryLabel {
    switch (category) {
      case PostCategory.question: return 'Question';
      case PostCategory.tip: return 'Tip';
      case PostCategory.market: return 'Market';
      case PostCategory.free: return 'Free';
    }
  }
}