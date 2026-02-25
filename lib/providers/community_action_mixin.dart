import 'dart:io';
import 'package:flutter/material.dart';
import '../models/post.dart';
import '../services/community_service.dart';

/// 게시글의 생성(C), 수정(U), 삭제(D) 및 좋아요 액션을 분리한 Mixin입니다.
mixin CommunityActionMixin on ChangeNotifier {
  final CommunityService _service = CommunityService();
  bool _isLoadingAction = false;

  bool get isLoadingAction => _isLoadingAction;

  void _setLoading(bool value) {
    _isLoadingAction = value;
    notifyListeners();
  }

  // 게시글 추가 (Create)
  Future<void> addPost(Post post, {List<File>? images, required Function onRefresh}) async {
    _setLoading(true);
    try {
      final docRef = _service.getNewPostRef();
      final postId = docRef.id;

      List<String> uploadedUrls = [];
      if (images != null && images.isNotEmpty) {
        uploadedUrls = await _service.uploadPostImages(postId, images);
      }

      final postWithImages = Post(
        id: postId,
        title: post.title,
        content: post.content,
        author: post.author,
        authorId: post.authorId,
        authorName: post.authorName,
        createdAt: post.createdAt,
        category: post.category,
        isAnonymous: post.isAnonymous,
        likes: post.likes,
        comments: post.comments,
        imageUrls: uploadedUrls,
      );

      await _service.addPostWithId(postWithImages);
      await onRefresh(); // 목록 새로고침
    } catch (e) {
      debugPrint("Add post error: $e");
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // 게시글 수정 (Update)
  Future<void> updatePost(Post post, {
    List<File>? newImages,
    required List<String> remainingUrls,
    required Function onRefresh,
  }) async {
    _setLoading(true);
    try {
      List<String> finalUrls = List.from(remainingUrls);

      if (newImages != null && newImages.isNotEmpty) {
        final uploadedNewUrls = await _service.uploadPostImages(post.id, newImages, prefix: "update");
        finalUrls.addAll(uploadedNewUrls);
      }

      final updatedPost = Post(
        id: post.id,
        title: post.title,
        content: post.content,
        author: post.author,
        authorId: post.authorId,
        authorName: post.authorName,
        createdAt: post.createdAt,
        category: post.category,
        isAnonymous: post.isAnonymous,
        likes: post.likes,
        comments: post.comments,
        imageUrls: finalUrls,
      );

      await _service.updatePost(updatedPost);
      await onRefresh();
    } catch (e) {
      debugPrint("Update post error: $e");
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // 게시글 삭제 (Delete)
  Future<void> deletePost(String postId) async {
    try {
      await _service.deletePost(postId);
      notifyListeners();
    } catch (e) {
      debugPrint("Delete post error: $e");
      rethrow;
    }
  }

  // 좋아요 토글
  Future<void> toggleLike(String postId, String userId) async {
    try {
      await _service.toggleLike(postId, userId);
    } catch (e) {
      debugPrint("Toggle like error: $e");
    }
  }
}