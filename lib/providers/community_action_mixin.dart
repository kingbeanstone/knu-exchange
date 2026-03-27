import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  // [수정] 파라미터 이름을 화면(Screen) 호출부와 100% 일치시키고 로딩 해제 보장
  Future<void> blockUser({
    required String currentUserId,
    required String blockedUserId,
    required String blockedUserName,
    required VoidCallback onBlockedUI,
  }) async {
    _setLoading(true); // 빙글빙글 시작
    try {
      // Firestore 차단 목록 업데이트
      await FirebaseFirestore.instance
          .collection('artifacts')
          .doc('knu-exchange-app')
          .collection('users')
          .doc(currentUserId)
          .collection('profile')
          .doc('info')
          .set({
        'blockedUsers': FieldValue.arrayUnion([blockedUserId]),
      }, SetOptions(merge: true));

      // UI에서 즉시 글을 삭제하는 콜백 실행 (애플 Guideline 1.2 대응)
      onBlockedUI();

      debugPrint("📢 $blockedUserName 유저 차단 완료");
    } catch (e) {
      debugPrint("Block user error: $e");
    } finally {
      _setLoading(false); // [핵심] 성공/실패와 상관없이 빙글빙글 종료
    }
  }

  // 게시글 신고 로직 (애플 가이드라인 준수)
  Future<void> reportPost({
    required String postId,
    required String reporterId,
    required String reason,
  }) async {
    _setLoading(true);
    try {
      await FirebaseFirestore.instance
          .collection('artifacts')
          .doc('knu-exchange-app')
          .collection('public')
          .doc('data')
          .collection('reports')
          .add({
        'postId': postId,
        'reporterId': reporterId,
        'reason': reason,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint("Report error: $e");
    } finally {
      _setLoading(false); // 로딩 해제
    }
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

  Future<void> deletePost(String postId) async {
    _setLoading(true); // 삭제 시에도 로딩 상태 관리 추가
    try {
      await _service.deletePost(postId);
      notifyListeners();
    } catch (e) {
      debugPrint("Delete post error: $e");
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> toggleLike(String postId, String userId) async {
    try {
      await _service.toggleLike(postId, userId);
    } catch (e) {
      debugPrint("Toggle like error: $e");
    }
    // 좋아요는 보통 전체 화면 로딩을 걸지 않으므로 setLoading을 생략하거나 필요 시 추가합니다.
  }
}