import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/post.dart';

class CommunityService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final String _appId = 'knu-exchange-app';

  CollectionReference get _postsRef =>
      _db.collection('artifacts').doc(_appId).collection('public').doc('data').collection('posts');

  DocumentReference getNewPostRef() => _postsRef.doc();

  Future<DocumentSnapshot> getPostById(String postId) async {
    return await _postsRef.doc(postId).get();
  }

  Future<List<String>> uploadPostImages(String postId, List<File> images, {String prefix = "img"}) async {
    List<String> urls = [];
    for (int i = 0; i < images.length; i++) {
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final ref = _storage.ref().child('artifacts/$_appId/posts/$postId/${prefix}_${timestamp}_$i.jpg');
      await ref.putFile(images[i]);
      final url = await ref.getDownloadURL();
      urls.add(url);
    }
    return urls;
  }

  Future<QuerySnapshot> getPostsQuery({
    int limit = 10,
    DocumentSnapshot? startAfter,
    bool sortByLikes = false,
    String? authorId,
    PostCategory? category,
  }) async {
    Query query = _postsRef;

    if (authorId != null) {
      query = query.where('authorId', isEqualTo: authorId);
    }
    else if (category != null && category != PostCategory.hot) {
      query = query.where('category', isEqualTo: category.toString().split('.').last);
    }

    if (sortByLikes || category == PostCategory.hot) {
      query = query.orderBy('likes', descending: true).orderBy('createdAt', descending: true);
    } else {
      query = query.orderBy('createdAt', descending: true);
    }

    query = query.limit(limit);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    return await query.get();
  }

  // [수정] 포함 단어 검색을 위해 최근 게시글들을 풀(Pool)로 가져오는 메서드
  // Firestore는 포함(contains) 검색을 직접 지원하지 않으므로 클라이언트에서 필터링하기 위해 데이터를 가져옵니다.
  Future<List<Post>> fetchPostsForSearch() async {
    // 최근 100개의 게시글을 가져와서 검색 대상으로 삼습니다.
    final snapshot = await _postsRef
        .orderBy('createdAt', descending: true)
        .limit(100)
        .get();

    return snapshot.docs.map((doc) {
      return Post.fromFirestore(doc.id, doc.data() as Map<String, dynamic>);
    }).toList();
  }

  Future<void> addPostWithId(Post post) async {
    await _postsRef.doc(post.id).set(post.toFirestore());
  }

  Future<void> updatePost(Post post) async {
    await _postsRef.doc(post.id).update(post.toFirestore());
  }

  Future<void> deletePost(String postId) async {
    await _postsRef.doc(postId).delete();
  }

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

  DocumentReference _userRef(String userId) =>
      _db.collection('artifacts').doc(_appId).collection('users').doc(userId);

  Future<void> updateFcmToken(String userId, String token) async {
    await _userRef(userId).set({
      'fcmToken': token,
      'lastUpdated': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}