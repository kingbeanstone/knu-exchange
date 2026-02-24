import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/post.dart';

class CommunityService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _appId = 'knu-exchange-app';

  CollectionReference get _postsRef =>
      _db.collection('artifacts').doc(_appId).collection('public').doc('data').collection('posts');

  // [수정] 페이징 처리를 위한 메서드
  Future<QuerySnapshot> getPostsQuery({int limit = 10, DocumentSnapshot? startAfter}) async {
    Query query = _postsRef.orderBy('createdAt', descending: true).limit(limit);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    return await query.get();
  }

  // 실시간 스트림 (페이징 시에는 보통 첫 페이지만 실시간으로 보거나 Future 방식을 선호함)
  Stream<List<Post>> streamPosts() {
    return _postsRef
        .orderBy('createdAt', descending: true)
        .limit(20) // 초기 로드 제한
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
      'isAnonymous': post.isAnonymous ?? false,
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