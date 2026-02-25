import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/comment.dart';

class CommentService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _appId = 'knu-exchange-app';

  DocumentReference _postRef(String postId) =>
      _db
          .collection('artifacts')
          .doc(_appId)
          .collection('public')
          .doc('data')
          .collection('posts')
          .doc(postId);

  Future<List<Comment>> fetchComments(String postId) async {
    final snapshot = await _postRef(postId)
        .collection('comments')
        .orderBy('createdAt', descending: false)
        .get();

    return snapshot.docs.map((doc) => Comment.fromFirestore(doc)).toList();
  }

  Future<void> addComment(String postId, Comment comment) async {
    final postRef = _postRef(postId);
    final commentsRef = postRef.collection('comments');

    final postSnap = await postRef.get();
    final postData = postSnap.data() as Map<String, dynamic>?;

    String finalAuthorName = comment.author;

    // 익명 처리 로직 유지
    if (comment.isAnonymous) {
      final snapshot =
      await commentsRef.orderBy('createdAt', descending: false).get();

      final allComments =
      snapshot.docs.map((doc) => Comment.fromFirestore(doc)).toList();

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

    // 댓글 수 증가
    batch.update(postRef, {
      'comments': FieldValue.increment(1),
    });

    await batch.commit();
  }

  Future<void> deleteComment(String postId, String commentId) async {
    final postRef = _postRef(postId);
    final commentRef = postRef.collection('comments').doc(commentId);

    final batch = _db.batch();

    batch.delete(commentRef);

    batch.update(postRef, {
      'comments': FieldValue.increment(-1),
    });

    await batch.commit();
  }
}