import 'package:flutter/material.dart';
import '../models/comment.dart';
import '../services/comment_service.dart';

class CommentProvider with ChangeNotifier {
  final CommentService _service = CommentService();

  List<Comment> _comments = [];
  bool _isLoading = false;
  Comment? _replyingTo;

  List<Comment> get comments => _comments;
  bool get isLoading => _isLoading;
  Comment? get replyingTo => _replyingTo;

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

  // [추가] 댓글 좋아요 토글 로직
  Future<void> toggleCommentLike(String postId, String commentId, String userId) async {
    try {
      await _service.toggleCommentLike(postId, commentId, userId);
      // 최신 데이터를 반영하기 위해 댓글 목록 다시 로드
      await loadComments(postId);
    } catch (e) {
      debugPrint("Comment like toggle error: $e");
      rethrow;
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
      parentId: _replyingTo?.id,
      replyToName: _replyingTo?.author,
    );

    try {
      await _service.addComment(postId, newComment);
      _replyingTo = null;
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