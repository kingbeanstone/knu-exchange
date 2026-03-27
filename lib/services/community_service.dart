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

  // 병렬 업로드 적용
  Future<List<String>> uploadPostImages(String postId, List<File> images, {String prefix = "img"}) async {
    if (images.isEmpty) return [];

    final uploadTasks = images.asMap().entries.map((entry) async {
      int i = entry.key;
      File image = entry.value;

      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final ref = _storage.ref().child('artifacts/$_appId/posts/$postId/${prefix}_${timestamp}_$i.jpg');

      await ref.putFile(image);
      return await ref.getDownloadURL();
    });

    return await Future.wait(uploadTasks);
  }

  /// 게시글 쿼리 메서드 (Hot 필터 로직 포함)
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

    // [수정] 핫 게시물 필터링: 최근 1주일 이내의 글만 필터링
    if (category == PostCategory.hot) {
      final oneWeekAgo = DateTime.now().subtract(const Duration(days: 7));
      query = query.where('createdAt', isGreaterThanOrEqualTo: oneWeekAgo);

      // Firestore 제약상 범위 쿼리 시 첫 번째 정렬은 필터링 필드(createdAt)여야 함
      query = query.orderBy('createdAt', descending: true);

      // 상위 10개를 정확히 뽑기 위해 최근 1주일치 글을 최대 100개까지 가져옵니다.
      query = query.limit(100);
    }
    else if (sortByLikes) {
      query = query.orderBy('likes', descending: true).orderBy('createdAt', descending: true);
      query = query.limit(limit);
    }
    else {
      query = query.orderBy('createdAt', descending: true);
      query = query.limit(limit);
    }

    // 핫 게시물은 전체 정렬이 필요하므로 페이징(startAfter)을 적용하지 않습니다.
    if (startAfter != null && category != PostCategory.hot) {
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