import 'package:flutter/material.dart';
import '../models/comment.dart';
import '../services/comment_service.dart';

class CommentProvider with ChangeNotifier {
  final CommentService _service = CommentService();

  List<Comment> _comments = [];
  bool _isLoading = false;

  // [추가] 대댓글 작성을 위한 상태
  Comment? _replyingTo;

  List<Comment> get comments => _comments;
  bool get isLoading => _isLoading;
  Comment? get replyingTo => _replyingTo;

  // 특정 댓글에 답글 달기 모드 설정
  void setReplyingTo(Comment? comment) {
    _replyingTo = comment;
    notifyListeners();
  }

  Future<void> loadComments(String postId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _comments = await _service.fetchComments(postId);
    } catch (e) {
      debugPrint("Comment load error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addComment(
      String postId,
      String author,
      String authorId,
      String content, {
        bool isAnonymous = false,
      }) async {
    final newComment = Comment(
      id: '',
      author: author,
      authorId: authorId,
      content: content,
      createdAt: DateTime.now(),
      isAnonymous: isAnonymous,
      parentId: _replyingTo?.id,        // [추가] 답글인 경우 부모 ID 저장
      replyToName: _replyingTo?.author, // [추가] 답글 대상자 이름 저장
    );

    try {
      await _service.addComment(postId, newComment);
      _replyingTo = null; // 전송 후 답글 모드 해제
      await loadComments(postId);
    } catch (e) {
      debugPrint("Comment add error: $e");
      rethrow;
    }
  }

  Future<void> removeComment(String postId, String commentId) async {
    try {
      await _service.deleteComment(postId, commentId);
      await loadComments(postId);
    } catch (e) {
      debugPrint("Comment delete error: $e");
      rethrow;
    }
  }
}