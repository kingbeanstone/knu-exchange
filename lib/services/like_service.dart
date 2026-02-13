import 'package:cloud_firestore/cloud_firestore.dart';

class LikeService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _appId = 'knu-exchange-app';

  DocumentReference _postRef(String postId) =>
      _db.collection('artifacts').doc(_appId).collection('public').doc('data').collection('posts').doc(postId);

  // 좋아요 토글 (트랜잭션 기반으로 정합성 유지)
  Future<void> toggleLike(String postId, String userId) async {
    final postDoc = _postRef(postId);
    final likeDoc = postDoc.collection('likes').doc(userId);

    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(likeDoc);

      if (snapshot.exists) {
        transaction.delete(likeDoc);
        transaction.update(postDoc, {'likes': FieldValue.increment(-1)});
      } else {
        transaction.set(likeDoc, {
          'userId': userId,
          'createdAt': FieldValue.serverTimestamp(),
        });
        transaction.update(postDoc, {'likes': FieldValue.increment(1)});
      }
    });
  }

  // 좋아요 여부 단발성 확인
  Future<bool> checkIsLiked(String postId, String userId) async {
    if (userId.isEmpty) return false;
    final doc = await _postRef(postId).collection('likes').doc(userId).get();
    return doc.exists;
  }
}