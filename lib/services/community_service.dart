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

  // [속도 개선] 병렬 업로드 적용
  // 기존: for 루프로 한 장씩 순차 업로드 (1번 끝날 때까지 2번 대기)
  // 변경: Future.wait를 사용해 모든 이미지를 동시에 업로드 시작
  Future<List<String>> uploadPostImages(String postId, List<File> images, {String prefix = "img"}) async {
    if (images.isEmpty) return [];

    // 각 이미지 업로드 작업을 생성
    final uploadTasks = images.asMap().entries.map((entry) async {
      int i = entry.key;
      File image = entry.value;

      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final ref = _storage.ref().child('artifacts/$_appId/posts/$postId/${prefix}_${timestamp}_$i.jpg');

      // 파일 업로드 (비동기 실행)
      await ref.putFile(image);
      // 다운로드 URL 반환
      return await ref.getDownloadURL();
    });

    // 모든 업로드 작업이 완료될 때까지 대기 (병렬 처리)
    return await Future.wait(uploadTasks);
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

  Future<List<Post>> fetchPostsForSearch() async {
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