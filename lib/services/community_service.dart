import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/post.dart';

class CommunityService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _appId = 'knu-exchange-app';

  CollectionReference get _postsRef =>
      _db.collection('artifacts').doc(_appId).collection('public').doc('data').collection('posts');

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

  // [기존] 게시글 추가
  Future<void> addPost(String title, String content, PostCategory category) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final String nickname = user.displayName ?? user.email?.split('@')[0] ?? 'Anonymous';

    await _postsRef.add({
      'title': title,
      'content': content,
      'author': nickname,
      'authorId': user.uid,
      'category': category.name,
      'createdAt': FieldValue.serverTimestamp(),
      'likes': 0,
      'commentCount': 0,
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
}