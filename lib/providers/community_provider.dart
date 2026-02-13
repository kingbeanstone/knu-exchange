import 'dart:async';
import 'package:flutter/material.dart';
import '../models/post.dart';
import '../services/community_service.dart';

class CommunityProvider with ChangeNotifier {
  final CommunityService _service = CommunityService();
  List<Post> _posts = [];
  bool _isLoading = true;
  StreamSubscription? _subscription;

  List<Post> get posts => _posts;
  bool get isLoading => _isLoading;

  CommunityProvider() {
    _init();
  }

  void _init() {
    _subscription = _service.getPostsStream().listen((newList) {
      _posts = newList;
      _posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      _isLoading = false;
      notifyListeners();
    }, onError: (error) {
      _isLoading = false;
      notifyListeners();
    });
  }

  // [수정] 좋아요 토글 호출
  Future<void> toggleLike(String postId, String userId) async {
    try {
      await _service.toggleLike(postId, userId);
    } catch (e) {
      debugPrint("Toggle Like Error: $e");
      rethrow;
    }
  }

  // 좋아요 상태 확인 스트림 제공
  Stream<bool> isLiked(String postId, String userId) {
    return _service.isLikedStream(postId, userId);
  }

  Future<void> createPost(String title, String content, String author, PostCategory category) async {
    final newPost = Post(
      id: '',
      title: title,
      content: content,
      author: author,
      createdAt: DateTime.now(),
      category: category,
    );
    await _service.addPost(newPost);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}