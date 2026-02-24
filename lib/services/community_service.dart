import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/post.dart';

class CommunityService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _appId = 'knu-exchange-app';

  CollectionReference get _postsRef =>
      _db.collection('artifacts').doc(_appId).collection('public').doc('data').collection('posts');

  Stream<List<Post>> streamPosts() {
    return _postsRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Post.fromFirestore(
      doc.id,
      doc.data() as Map<String, dynamic>,
    ))
        .toList());
  }

  // [기존] 모든 게시글 가져오기
  Future<List<Post>> getPosts() async {
    final snapshot = await _postsRef.orderBy('createdAt', descending: true).get();
    return snapshot.docs.map((doc) => Post.fromFirestore(doc.id, doc.data() as Map<String, dynamic>)).toList();
  }

  // [기존] 특정 게시글 상세 가져오기
  Future<Post?> getPost(String postId) async {
    final doc = await _postsRef.doc(postId).get();
    if (!doc.exists) return null;
    return Post.fromFirestore(doc.id, doc.data() as Map<String, dynamic>);
  }

  Future<void> addPost(Post post) async {
    await _postsRef.add({
      'title': post.title,
      'content': post.content,
      'author': post.author,
      'authorId': post.authorId,
      'authorName': post.authorName,
      'createdAt': Timestamp.fromDate(post.createdAt),
      'category': post.category.toString(),
      'likes': post.likes,
      'comments': post.comments,
    });
  }

  // [강화] 게시글 삭제 (관리자 권한 대응)
  // Firestore 보안 규칙(Rules)에서 관리자 UID인 경우에만 타인의 글 삭제를 허용하도록 설정해야 합니다.
  Future<void> deletePost(String postId) async {
    try {
      await _postsRef.doc(postId).delete();
    } catch (e) {
      print('Error deleting post: $e');
      rethrow;
    }
  }

  Future<void> toggleLike(String postId, String userId) async {
    final doc = await _postsRef.doc(postId).get();
    final data = doc.data() as Map<String, dynamic>?;

    List likes = (data?['likes'] as List?) ?? [];

    if (likes.contains(userId)) {
      likes.remove(userId);
    } else {
      likes.add(userId);
    }

    await _postsRef.doc(postId).update({'likes': likes});
  }
}