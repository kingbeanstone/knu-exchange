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

  /// 🔥 Firestore 실시간 구독 시작
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

  /// 🔄 당겨서 새로고침 시 구독 재시작
  Future<void> fetchPosts() async {
    _startListening();
  }

  /// ➕ 게시글 추가
  Future<void> addPost(Post post) async {
    await _service.addPost(post);
    // Stream이 자동으로 업데이트함
  }

  /// ❌ 게시글 삭제
  Future<void> deletePost(String postId) async {
    await _service.deletePost(postId);
    // Stream이 자동 반영
  }

  /// ❤️ 좋아요 토글
  Future<void> toggleLike(String postId, String userId) async {
    await _service.toggleLike(postId, userId);
    // Stream 자동 반영
  }

  @override
  void dispose() {
    _postsSubscription?.cancel();
    super.dispose();
  }
}