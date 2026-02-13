import 'package:cloud_firestore/cloud_firestore.dart';

class LikeService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _appId = 'knu-exchange-app';

  // 게시글 참조를 위한 베이스 경로
  DocumentReference _postDoc(String postId) =>
      _db.collection('artifacts').doc(_appId).collection('public').doc('data').collection('posts').doc(postId);

  // 좋아요 토글 로직 (기존 로직 유지)
  Future<void> toggleLike(String postId, String userId) async {
    final postRef = _postDoc(postId);
    final likeRef = postRef.collection('likes').doc(userId);

    await _db.runTransaction((transaction) async {
      final likeDoc = await transaction.get(likeRef);

      if (likeDoc.exists) {
        // 이미 좋아요를 누른 경우: 기록 삭제 및 카운트 -1
        transaction.delete(likeRef);
        transaction.update(postRef, {'likes': FieldValue.increment(-1)});
      } else {
        // 처음 누르는 경우: 기록 생성 및 카운트 +1
        transaction.set(likeRef, {'createdAt': FieldValue.serverTimestamp()});
        transaction.update(postRef, {'likes': FieldValue.increment(1)});
      }
    });
  }

  // 특정 유저의 좋아요 여부 확인 스트림 (기존 로직 유지)
  Stream<bool> isLikedStream(String postId, String userId) {
    if (userId.isEmpty) return Stream.value(false);
    return _postDoc(postId)
        .collection('likes')
        .doc(userId)
        .snapshots()
        .map((doc) => doc.exists);
  }
}