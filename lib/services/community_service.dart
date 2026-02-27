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

    // 1. 작성자 필터링 (My Posts)
    if (authorId != null) {
      query = query.where('authorId', isEqualTo: authorId);
    }
    // 2. 카테고리 필터링 (Hot 제외 - Hot은 정렬 조건임)
    else if (category != null && category != PostCategory.hot) {
      // [수정 핵심] enum.toString() 대신 split('.').last를 사용하여 "lounge" 형태의 문자열로 쿼리
      query = query.where('category', isEqualTo: category.toString().split('.').last);
    }

    // 3. 정렬 조건 설정
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

  Future<List<Post>> searchPosts(String queryText) async {
    final snapshot = await _postsRef
        .orderBy('title')
        .startAt([queryText])
        .endAt([queryText + '\uf8ff'])
        .limit(20)
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

    // Likes 필드가 리스트인 경우 (ID 중복 체크용)
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