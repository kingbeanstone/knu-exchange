import 'dart:async';
import 'package:flutter/material.dart';
import '../models/post.dart';
import '../services/community_service.dart';

class CommunityProvider with ChangeNotifier {
  final CommunityService _service = CommunityService();

  List<Post> _posts = [];
  bool _isLoading = true;

  StreamSubscription<List<Post>>? _postsSubscription;

  List<Post> get posts => _posts;
  bool get isLoading => _isLoading;

  CommunityProvider() {
    _startListening();
  }

  /// Firestore 실시간 구독 시작
  void _startListening() {
    _isLoading = true;
    notifyListeners();

    _postsSubscription?.cancel();

    _postsSubscription = _service.streamPosts().listen(
          (posts) {
        _posts = posts;
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        debugPrint("Community stream error: $error");
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  /// 당겨서 새로고침
  Future<void> fetchPosts() async {
    _startListening();
  }

  /// 게시글 추가
  /// [Post] 객체의 isAnonymous 값에 따라 서비스에서 처리됩니다.
  Future<void> addPost(Post post) async {
    try {
      await _service.addPost(post);
    } catch (e) {
      debugPrint("Add post error: $e");
      rethrow;
    }
  }

  /// 게시글 삭제
  Future<void> deletePost(String postId) async {
    try {
      await _service.deletePost(postId);
    } catch (e) {
      debugPrint("Delete post error: $e");
      rethrow;
    }
  }

  /// 좋아요 토글
  Future<void> toggleLike(String postId, String userId) async {
    try {
      await _service.toggleLike(postId, userId);
    } catch (e) {
      debugPrint("Toggle like error: $e");
      rethrow;
    }
  }

  @override
  void dispose() {
    _postsSubscription?.cancel();
    super.dispose();
  }
}