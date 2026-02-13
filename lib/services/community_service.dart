import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/post.dart';

class CommunityService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  // 앱 ID 설정 (환경 변수 또는 기본값 사용)
  final String _appId = 'knu-exchange-app';

  // 게시글 컬렉션 참조 (규칙 준수: artifacts/{appId}/public/data/posts)
  CollectionReference get _postsRef =>
      _db.collection('artifacts').doc(_appId).collection('public').doc('data').collection('posts');

  // 모든 게시글 스트림 가져오기 (실시간 업데이트)
  Stream<List<Post>> getPostsStream() {
    return _postsRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Post(
          id: doc.id,
          title: data['title'] ?? '',
          content: data['content'] ?? '',
          author: data['author'] ?? 'Anonymous',
          createdAt: (data['createdAt'] as Timestamp).toDate(),
          category: PostCategory.values.firstWhere(
                (e) => e.toString() == data['category'],
            orElse: () => PostCategory.free,
          ),
          likes: data['likes'] ?? 0,
          comments: data['comments'] ?? 0,
        );
      }).toList();
    });
  }

  // 게시글 작성하기
  Future<void> addPost(Post post) async {
    await _postsRef.add({
      'title': post.title,
      'content': post.content,
      'author': post.author,
      'createdAt': Timestamp.fromDate(post.createdAt),
      'category': post.category.toString(),
      'likes': post.likes,
      'comments': post.comments,
    });
  }
}