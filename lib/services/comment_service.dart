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
        .orderBy('createdAt', descending: false) // 시간순 정렬 (번호 부여를 위해)
        .get();

    return snapshot.docs.map((doc) => Comment.fromFirestore(doc)).toList();
  }

  // [핵심] 익명 번호 부여 로직이 포함된 댓글 추가
  Future<void> addComment(String postId, Comment comment) async {
    final postRef = _postRef(postId);
    final commentsRef = postRef.collection('comments');

    String finalAuthorName = comment.author;

    // 익명 작성 시 번호 계산
    if (comment.isAnonymous) {
      // 1. 해당 포스트의 모든 댓글을 가져옴
      final snapshot = await commentsRef.orderBy('createdAt', descending: false).get();
      final allComments = snapshot.docs.map((doc) => Comment.fromFirestore(doc)).toList();

      // 2. 익명으로 작성한 유저들의 ID 목록을 순서대로 추출 (중복 제거)
      final List<String> anonymousUserIds = [];
      for (var c in allComments) {
        if (c.isAnonymous && !anonymousUserIds.contains(c.authorId)) {
          anonymousUserIds.add(c.authorId);
        }
      }

      // 3. 현재 작성자가 이미 익명으로 참여했는지 확인
      int userIndex = anonymousUserIds.indexOf(comment.authorId);

      if (userIndex != -1) {
        // 이미 익명으로 썼던 유저라면 기존 번호 유지
        finalAuthorName = "Anonymous ${userIndex + 1}";
      } else {
        // 처음 익명으로 쓰는 유저라면 새로운 번호 부여
        finalAuthorName = "Anonymous ${anonymousUserIds.length + 1}";
      }
    }

    final commentRef = commentsRef.doc();
    final batch = _db.batch();

    // 작성자 이름을 계산된 이름으로 변경하여 저장
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