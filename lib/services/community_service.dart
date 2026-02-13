import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/post.dart';

class CommunityService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _appId = 'knu-exchange-app';

  CollectionReference get _postsRef =>
      _db.collection('artifacts').doc(_appId).collection('public').doc('data').collection('posts');

  Stream<List<Post>> getPostsStream() {
    return _postsRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Post(
          id: doc.id,
          title: data['title'] ?? '',
          content: data['content'] ?? '',
          author: data['author'] ?? 'Anonymous',
          createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          category: PostCategory.values.firstWhere(
                (e) => e.toString() == data['category'],
            orElse: () => PostCategory.free,
          ),
          likes: data['likes'] ?? 0,
          comments: data['comments'] ?? 0,
        );
      }).toList();
    });
  }

  Future<void> addPost(Post post) async {
    final user = FirebaseAuth.instance.currentUser;
    await _postsRef.add({
      'title': post.title,
      'content': post.content,
      'author': post.author,
      'authorId': user?.uid,
      'createdAt': FieldValue.serverTimestamp(),
      'category': post.category.toString(),
      'likes': 0,
      'comments': 0,
    });
  }

  // [수정] 좋아요 토글 로직 (중복 방지)
  Future<void> toggleLike(String postId, String userId) async {
    // 유저가 해당 포스트에 남긴 좋아요 문서 참조
    final likeRef = _postsRef.doc(postId).collection('likes').doc(userId);

    // 트랜잭션을 사용하여 데이터 일관성 보장
    await _db.runTransaction((transaction) async {
      final likeDoc = await transaction.get(likeRef);
      final postRef = _postsRef.doc(postId);

      if (likeDoc.exists) {
        // 이미 좋아요를 누른 경우: 좋아요 기록 삭제 및 카운트 -1
        transaction.delete(likeRef);
        transaction.update(postRef, {'likes': FieldValue.increment(-1)});
      } else {
        // 처음 누르는 경우: 좋아요 기록 생성 및 카운트 +1
        transaction.set(likeRef, {'createdAt': FieldValue.serverTimestamp()});
        transaction.update(postRef, {'likes': FieldValue.increment(1)});
      }
    });
  }

  // 특정 유저가 이 글에 좋아요를 눌렀는지 확인하는 스트림
  Stream<bool> isLikedStream(String postId, String userId) {
    return _postsRef
        .doc(postId)
        .collection('likes')
        .doc(userId)
        .snapshots()
        .map((doc) => doc.exists);
  }
}