import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/post.dart';

class CommunityService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _appId = 'knu-exchange-app';

  // Firestore 경로 설정 (공개 데이터 저장소)
  CollectionReference get _postsRef =>
      _db.collection('artifacts').doc(_appId).collection('public').doc('data').collection('posts');

  // 게시글 실시간 스트림
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

  // 모든 게시글 가져오기
  Future<List<Post>> getPosts() async {
    final snapshot = await _postsRef.orderBy('createdAt', descending: true).get();
    return snapshot.docs.map((doc) => Post.fromFirestore(doc.id, doc.data() as Map<String, dynamic>)).toList();
  }

  // 특정 게시글 상세 가져오기
  Future<Post?> getPost(String postId) async {
    final doc = await _postsRef.doc(postId).get();
    if (!doc.exists) return null;
    return Post.fromFirestore(doc.id, doc.data() as Map<String, dynamic>);
  }

  // 게시글 추가 (익명 필드 포함)
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
      'isAnonymous': post.isAnonymous, // [추가] 익명 여부 저장
    });
  }

  // 게시글 삭제
  Future<void> deletePost(String postId) async {
    try {
      await _postsRef.doc(postId).delete();
    } catch (e) {
      print('Error deleting post: $e');
      rethrow;
    }
  }

  // 좋아요 토글 로직
  Future<void> toggleLike(String postId, String userId) async {
    final docRef = _postsRef.doc(postId);
    final doc = await docRef.get();
    final data = doc.data() as Map<String, dynamic>?;

    List likes = (data?['likes'] as List?) ?? [];

    if (likes.contains(userId)) {
      likes.remove(userId);
    } else {
      likes.add(userId);
    }

    await docRef.update({'likes': likes});
  }
}