import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/comment.dart';

class CommentService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _appId = 'knu-exchange-app';

  DocumentReference _postRef(String postId) =>
      _db.collection('artifacts').doc(_appId).collection('public').doc('data').collection('posts').doc(postId);

  Future<List<Comment>> fetchComments(String postId) async {
    final snapshot = await _postRef(postId)
        .collection('comments')
        .orderBy('createdAt', descending: false)
        .get();

    return snapshot.docs.map((doc) => Comment.fromFirestore(doc)).toList();
  }

  // [추가] 댓글 좋아요 토글 메서드
  Future<void> toggleCommentLike(String postId, String commentId, String userId) async {
    final commentRef = _postRef(postId).collection('comments').doc(commentId);

    // 문서의 현재 상태를 가져와서 좋아요 여부 판단
    final doc = await commentRef.get();
    if (!doc.exists) return;

    final data = doc.data() as Map<String, dynamic>;
    List<String> likes = List<String>.from(data['likes'] ?? []);

    if (likes.contains(userId)) {
      // 이미 좋아요를 눌렀다면 제거
      await commentRef.update({
        'likes': FieldValue.arrayRemove([userId])
      });
    } else {
      // 누르지 않았다면 추가
      await commentRef.update({
        'likes': FieldValue.arrayUnion([userId])
      });
    }
  }

  Future<void> addComment(String postId, Comment comment) async {
    final postRef = _postRef(postId);
    final commentsRef = postRef.collection('comments');
    String finalAuthorName = comment.author;

    if (comment.isAnonymous) {
      final snapshot = await commentsRef.orderBy('createdAt', descending: false).get();
      final allComments = snapshot.docs.map((doc) => Comment.fromFirestore(doc)).toList();

      final List<String> anonymousUserIds = [];
      for (var c in allComments) {
        if (c.isAnonymous && !anonymousUserIds.contains(c.authorId)) {
          anonymousUserIds.add(c.authorId);
        }
      }

      int userIndex = anonymousUserIds.indexOf(comment.authorId);
      if (userIndex != -1) {
        finalAuthorName = "Anonymous ${userIndex + 1}";
      } else {
        finalAuthorName = "Anonymous ${anonymousUserIds.length + 1}";
      }
    }

    final commentRef = commentsRef.doc();
    final batch = _db.batch();

    final commentData = comment.toFirestore();
    commentData['author'] = finalAuthorName;

    batch.set(commentRef, commentData);
    batch.update(postRef, {'comments': FieldValue.increment(1)});

    await batch.commit();
  }

  Future<void> deleteComment(String postId, String commentId) async {
    final postRef = _postRef(postId);
    final commentRef = postRef.collection('comments').doc(commentId);
    final batch = _db.batch();
    batch.delete(commentRef);
    batch.update(postRef, {'comments': FieldValue.increment(-1)});
    await batch.commit();
  }
}