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

  // [추가] 특정 ID로 게시글 가져오기 (알림 이동 시 필수)
  Future<DocumentSnapshot> getPostById(String postId) async {
    return await _postsRef.doc(postId).get();
  }

  // [수정] prefix 파라미터 정의 추가
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

  // [수정] authorId와 category 파라미터 정의 추가
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
    } else if (category != null && category != PostCategory.hot) {
      query = query.where('category', isEqualTo: category.toString());
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

  // [추가] 게시글 검색 메서드 정의
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

  // [추가] 게시글 수정 메서드 정의
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

  // 유저 정보 경로 (FCM 토큰 저장용)
  DocumentReference _userRef(String userId) =>
      _db.collection('artifacts').doc(_appId).collection('users').doc(userId);

  // FCM 토큰 저장
  Future<void> updateFcmToken(String userId, String token) async {
    await _userRef(userId).set({
      'fcmToken': token,
      'lastUpdated': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // 상대방의 FCM 토큰 조회
  Future<String?> getUserFcmToken(String userId) async {
    final doc = await _userRef(userId).get();
    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>?;
      return data?['fcmToken'];
    }
    return null;
  }
}