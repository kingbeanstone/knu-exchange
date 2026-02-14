import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/post.dart';

class CommunityService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _appId = 'knu-exchange-app';

  CollectionReference get _postsRef =>
      _db.collection('artifacts').doc(_appId).collection('public').doc('data').collection('posts');

  // 게시글 전체 목록 조회 (Future 기반)
  Future<List<Post>> getPosts() async {
    final snapshot = await _postsRef.get();
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return Post(
        id: doc.id,
        title: data['title'] ?? '',
        content: data['content'] ?? '',
        author: data['author'] ?? 'Anonymous',
        createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        category: PostCategory.values.firstWhere(
              (e) => e.toString() == data['category'],
          orElse: () => PostCategory.free,
        ),
        likes: data['likes'] ?? 0,
        comments: data['comments'] ?? 0,
      );
    }).toList();
  }

  // [추가] 특정 게시글 단건 조회 (상세 페이지 진입 시 호출)
  Future<Post?> getPost(String postId) async {
    final doc = await _postsRef.doc(postId).get();
    if (!doc.exists) return null;

    final data = doc.data() as Map<String, dynamic>;
    return Post(
      id: doc.id,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      author: data['author'] ?? 'Anonymous',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      category: PostCategory.values.firstWhere(
            (e) => e.toString() == data['category'],
        orElse: () => PostCategory.free,
      ),
      likes: data['likes'] ?? 0,
      comments: data['comments'] ?? 0,
    );
  }

  Future<void> addPost(Post post) async {
    final user = FirebaseAuth.instance.currentUser;
    await _postsRef.add({
      'title': post.title,
      'content': post.content,
      'author': post.author,
      'authorId': user?.uid,
      'createdAt': FieldValue.serverTimestamp(),
      'category': post.category.toString(),
      'likes': 0,
      'comments': 0,
    });
  }
}