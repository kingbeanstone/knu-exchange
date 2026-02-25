import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/comment.dart';
import '../models/notification_item.dart'; // [추가]
import 'notification_service.dart';     // [추가]

class CommentService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _appId = 'knu-exchange-app';
  final NotificationService _notifService = NotificationService(); // [추가]

  DocumentReference _postRef(String postId) =>
      _db.collection('artifacts').doc(_appId).collection('public').doc('data').collection('posts').doc(postId);

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

    // 1. 알림을 위해 게시글 정보(작성자 ID, 제목) 미리 가져오기
    final postSnap = await postRef.get();
    final postData = postSnap.data() as Map<String, dynamic>?;
    final String postAuthorId = postData?['authorId'] ?? '';
    final String postTitle = postData?['title'] ?? 'your post';

    String finalAuthorName = comment.author;

    // 2. 익명 번호 부여 로직
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

    // 3. [알림 발송] 게시글 작성자에게 새 댓글 알림 전송
    await _notifService.sendNotification(NotificationItem(
      id: '',
      targetUserId: postAuthorId,
      senderId: comment.authorId,
      senderName: finalAuthorName, // 계산된 익명 이름 사용
      postId: postId,
      postTitle: postTitle,
      message: 'left a comment: "${comment.content}"',
      type: NotificationType.comment,
      createdAt: DateTime.now(),
    ));
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