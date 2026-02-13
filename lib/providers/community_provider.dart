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

  // 좋아요 관련 메서드는 LikeProvider로 이동되었습니다.

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}