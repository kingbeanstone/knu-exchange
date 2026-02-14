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

  // 게시글 목록 새로고침
  Future<void> fetchPosts() async {
    _isLoading = true;
    notifyListeners();
    try {
      _posts = await _service.getPosts();
      _posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      debugPrint("Fetch error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // [해결] PostDetailScreen에서 호출하는 단건 조회 메서드
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
}