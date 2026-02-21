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

  // 댓글 추가 (성공 시 로컬 리스트에 추가하여 즉시 반영)
  Future<void> addComment(String postId, String author, String authorId, String content) async {
    final newComment = Comment(
      id: '', // Firestore에서 자동 생성
      author: author,
      authorId: authorId,
      content: content,
      createdAt: DateTime.now(),
    );

    try {
      await _service.addComment(postId, newComment);
      // 작성 후 목록 다시 불러오기
      await loadComments(postId);
    } catch (e) {
      debugPrint("Comment add error: $e");
      rethrow;
    }
  }

  // [추가] 댓글 삭제
  Future<void> removeComment(String postId, String commentId) async {
    try {
      await _service.deleteComment(postId, commentId);
      // 삭제 후 목록 새로고침
      await loadComments(postId);
    } catch (e) {
      debugPrint("Comment delete error: $e");
      rethrow;
    }
  }
}