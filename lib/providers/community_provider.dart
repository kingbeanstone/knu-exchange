import 'package:flutter/material.dart';
import '../models/post.dart';
import '../services/community_service.dart';

class CommunityProvider with ChangeNotifier {
  final CommunityService _service = CommunityService();
  List<Post> _posts = [];
  bool _isLoading = false;

  List<Post> get posts => _posts;
  bool get isLoading => _isLoading;

  CommunityProvider() {
    fetchPosts();
  }

  Future<void> fetchPosts() async {
    _isLoading = true;
    notifyListeners();
    try {
      _posts = await _service.getPosts();
    } catch (e) {
      debugPrint("Fetch error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Post?> getPostDetail(String postId) async {
    return await _service.getPost(postId);
  }

  Future<void> createPost(String title, String content, PostCategory category) async {
    try {
      await _service.addPost(title, content, category);
      await fetchPosts();
    } catch (e) {
      debugPrint("Create Post Error: $e");
      rethrow;
    }
  }

  // [추가] 게시글 삭제 프로바이더 로직
  Future<void> removePost(String postId) async {
    try {
      await _service.deletePost(postId);
      await fetchPosts(); // 삭제 후 목록 새로고침
    } catch (e) {
      debugPrint("Delete Post Error: $e");
      rethrow;
    }
  }
}