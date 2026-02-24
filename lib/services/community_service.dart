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

  // [추가] 새 게시글 문서 레퍼런스 생성 (ID 선점용)
  DocumentReference getNewPostRef() => _postsRef.doc();

  // [추가] 이미지 업로드 로직
  Future<List<String>> uploadPostImages(String postId, List<File> images) async {
    List<String> urls = [];
    for (int i = 0; i < images.length; i++) {
      // 경로: artifacts/knu-exchange-app/posts/{postId}/img_{index}.jpg
      final ref = _storage.ref().child('artifacts/$_appId/posts/$postId/img_$i.jpg');

      // 파일 업로드
      await ref.putFile(images[i]);

      // 다운로드 URL 획득
      final url = await ref.getDownloadURL();
      urls.add(url);
    }
    return urls;
  }

  Future<QuerySnapshot> getPostsQuery({
    int limit = 10,
    DocumentSnapshot? startAfter,
    bool sortByLikes = false,
  }) async {
    Query query = _postsRef;
    if (sortByLikes) {
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

  // [수정] 특정 ID를 가진 게시글 추가 (ID를 미리 알고 있을 때 사용)
  Future<void> addPostWithId(Post post) async {
    await _postsRef.doc(post.id).set({
      'title': post.title,
      'content': post.content,
      'author': post.author,
      'authorId': post.authorId,
      'authorName': post.authorName,
      'createdAt': Timestamp.fromDate(post.createdAt),
      'category': post.category.toString(),
      'likes': post.likes,
      'comments': post.comments,
      'isAnonymous': post.isAnonymous,
      'imageUrls': post.imageUrls,
    });
  }

  // 기존 addPost는 호환성을 위해 유지 (ID 자동 생성)
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
      'isAnonymous': post.isAnonymous,
      'imageUrls': post.imageUrls,
    });
  }

  Future<void> deletePost(String postId) async {
    // 게시글 삭제 시 Storage 이미지들도 함께 정리하는 로직 권장
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