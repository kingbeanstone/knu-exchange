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

  // Firestore 스트림 구독 및 데이터 정렬
  void _init() {
    _subscription = _service.getPostsStream().listen((newList) {
      _posts = newList;
      // 최신순 정렬 (서버 부하 감소를 위해 메모리에서 수행)
      _posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      _isLoading = false;
      notifyListeners();
    }, onError: (error) {
      print("Community Stream Error: $error");
      _isLoading = false;
      notifyListeners();
    });
  }

  // 새 게시글 작성 요청
  Future<void> createPost(String title, String content, String author, PostCategory category) async {
    final newPost = Post(
      id: '', // Firestore에서 자동 생성됨
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