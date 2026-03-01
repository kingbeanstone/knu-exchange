import 'dart:io';
import 'package:flutter/material.dart';
import '../models/post.dart';
import '../services/community_service.dart';

mixin CommunityActionMixin on ChangeNotifier {
  final CommunityService _service = CommunityService();
  bool _isLoadingAction = false;

  bool get isLoadingAction => _isLoadingAction;

  void _setLoading(bool value) {
    _isLoadingAction = value;
    notifyListeners();
  }

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
      await onRefresh();
    } catch (e) {
      debugPrint("Add post error: $e");
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updatePost(Post post, {
    List<File>? newImages,
    required List<String> remainingUrls,
    required Function onRefresh,
  }) async {
    _setLoading(true);
    try {
      List<String> finalUrls = List.from(remainingUrls);

      if (newImages != null && newImages.isNotEmpty) {
        // [수정] 서비스의 uploadPostImages에 prefix 파라미터 전달
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

      // [수정] 서비스의 updatePost 호출
      await _service.updatePost(updatedPost);
      await onRefresh();
    } catch (e) {
      debugPrint("Update post error: $e");
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deletePost(String postId) async {
    try {
      await _service.deletePost(postId);
      notifyListeners();
    } catch (e) {
      debugPrint("Delete post error: $e");
      rethrow;
    }
  }

  Future<void> toggleLike(String postId, String userId) async {
    try {
      await _service.toggleLike(postId, userId);
    } catch (e) {
      debugPrint("Toggle like error: $e");
    }
  }
}