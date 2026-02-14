import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/post.dart';

class CommunityService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _appId = 'knu-exchange-app';

  CollectionReference get _postsRef =>
      _db.collection('artifacts').doc(_appId).collection('public').doc('data').collection('posts');

  Future<List<Post>> getPosts() async {
    final snapshot = await _postsRef.orderBy('createdAt', descending: true).get();
    return snapshot.docs.map((doc) => Post.fromFirestore(doc.id, doc.data() as Map<String, dynamic>)).toList();
  }

  Future<Post?> getPost(String postId) async {
    final doc = await _postsRef.doc(postId).get();
    if (!doc.exists) return null;
    return Post.fromFirestore(doc.id, doc.data() as Map<String, dynamic>);
  }

  Future<void> addPost(String title, String content, PostCategory category) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // 표시용 닉네임 결정
    final String nickname = user.displayName ?? user.email?.split('@')[0] ?? 'Anonymous';

    await _postsRef.add({
      'title': title,
      'content': content,
      'author': nickname,   // 표시용 이름 (닉네임)
      'authorId': user.uid, // 권한용 고유 ID (이 값이 핵심!)
      'createdAt': FieldValue.serverTimestamp(),
      'category': category.toString(),
      'likes': 0,
      'comments': 0,
    });
  }

  Future<void> deletePost(String postId) async {
    await _postsRef.doc(postId).delete();
  }
}