import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/post.dart';

class CommunityService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _appId = 'knu-exchange-app';

  CollectionReference get _postsRef =>
      _db.collection('artifacts').doc(_appId).collection('public').doc('data').collection('posts');

  // 페이징 처리를 위한 메서드
  Future<QuerySnapshot> getPostsQuery({int limit = 10, DocumentSnapshot? startAfter}) async {
    Query query = _postsRef.orderBy('createdAt', descending: true).limit(limit);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    return await query.get();
  }

  // [추가] 검색 쿼리 (방식 A: 제목 시작 단어 검색)
  Future<List<Post>> searchPosts(String queryText) async {
    // Firestore에서 특정 문자열로 시작하는 데이터를 찾는 쿼리
    // 예: 'apple' 검색 시 'apple' <= x < 'apple\uf8ff' 범위의 데이터를 찾음
    final snapshot = await _postsRef
        .orderBy('title')
        .startAt([queryText])
        .endAt([queryText + '\uf8ff'])
        .limit(20) // 검색 결과는 상위 20개만 우선 노출
        .get();

    return snapshot.docs.map((doc) {
      return Post.fromFirestore(doc.id, doc.data() as Map<String, dynamic>);
    }).toList();
  }

  // 실시간 스트림 (상단 20개)
  Stream<List<Post>> streamPosts() {
    return _postsRef
        .orderBy('createdAt', descending: true)
        .limit(20)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Post.fromFirestore(
      doc.id,
      doc.data() as Map<String, dynamic>,
    ))
        .toList());
  }

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