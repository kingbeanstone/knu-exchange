import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/comment.dart';

class CommentService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _appId = 'knu-exchange-app';

  // 게시글 문서 참조
  DocumentReference _postRef(String postId) =>
      _db.collection('artifacts').doc(_appId).collection('public').doc('data').collection('posts').doc(postId);

  // 댓글 목록 가져오기 (단발성)
  Future<List<Comment>> fetchComments(String postId) async {
    final snapshot = await _postRef(postId)
        .collection('comments')
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) => Comment.fromFirestore(doc)).toList();
  }

  // 댓글 작성 및 게시글 댓글 수 증가 (Batch)
  Future<void> addComment(String postId, Comment comment) async {
    final postRef = _postRef(postId);
    final commentRef = postRef.collection('comments').doc();

    final batch = _db.batch();
    batch.set(commentRef, comment.toFirestore());
    batch.update(postRef, {'comments': FieldValue.increment(1)});

    await batch.commit();
  }

  // [추가] 댓글 삭제 및 게시글 댓글 수 감소 (Batch)
  Future<void> deleteComment(String postId, String commentId) async {
    final postRef = _postRef(postId);
    final commentRef = postRef.collection('comments').doc(commentId);

    final batch = _db.batch();
    batch.delete(commentRef);
    batch.update(postRef, {'comments': FieldValue.increment(-1)});

    await batch.commit();
  }
}