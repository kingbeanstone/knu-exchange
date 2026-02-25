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

  // 새 게시글 문서 레퍼런스 생성 (ID 선점용)
  DocumentReference getNewPostRef() => _postsRef.doc();

  // [추가] 특정 ID로 게시글 문서 가져오기 (알림 이동 시 필요)
  Future<DocumentSnapshot> getPostById(String postId) async {
    return await _postsRef.doc(postId).get();
  }

  // 이미지 업로드 로직
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

  // 게시물 조회 쿼리 (카테고리 및 내 글 필터링 포함)
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
    await _postsRef.doc(post.id).update({
      'title': post.title,
      'content': post.content,
      'category': post.category.toString(),
      'isAnonymous': post.isAnonymous,
      'imageUrls': post.imageUrls,
    });
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
}