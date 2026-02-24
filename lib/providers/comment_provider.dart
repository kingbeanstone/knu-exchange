import 'package:flutter/material.dart';
import '../models/comment.dart';
import '../services/comment_service.dart';

class CommentProvider with ChangeNotifier {
  final CommentService _service = CommentService();

  List<Comment> _comments = [];
  bool _isLoading = false;

  List<Comment> get comments => _comments;
  bool get isLoading => _isLoading;

  // 특정 게시글의 댓글 목록 로드
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

  // 댓글 추가 (익명 여부 파라미터 추가 및 로직 강화)
  Future<void> addComment(
      String postId,
      String author,
      String authorId,
      String content,
      {bool isAnonymous = false} // [추가] 익명 여부
      ) async {
    final newComment = Comment(
      id: '',
      author: author,
      authorId: authorId,
      content: content,
      createdAt: DateTime.now(),
      isAnonymous: isAnonymous,
    );

    try {
      // 서비스에서 익명 번호 부여 로직을 처리하도록 수정됨
      await _service.addComment(postId, newComment);
      await loadComments(postId);
    } catch (e) {
      debugPrint("Comment add error: $e");
      rethrow;
    }
  }

  // 댓글 삭제
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