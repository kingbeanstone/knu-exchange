import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/post.dart';
import '../services/community_service.dart';

class CommunityProvider with ChangeNotifier {
  final CommunityService _service = CommunityService();

  List<Post> _posts = [];
  List<Post> _searchResults = [];
  String _searchQuery = "";
  PostCategory? _currentCategory;

  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _isSearching = false;
  bool _hasMore = true;
  DocumentSnapshot? _lastDocument;

  List<Post> get posts => _posts;
  List<Post> get searchResults => _searchResults;
  String get searchQuery => _searchQuery;
  PostCategory? get currentCategory => _currentCategory;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get isSearching => _isSearching;
  bool get hasMore => _hasMore;

  CommunityProvider() {
    fetchPosts(isRefresh: true);
  }

  void setCategory(PostCategory? category) {
    _currentCategory = category;
    fetchPosts(isRefresh: true);
  }

  Future<void> fetchPosts({bool isRefresh = false}) async {
    if (_isSearching && !isRefresh) return;

    if (isRefresh) {
      _isLoading = true;
      _hasMore = true;
      _lastDocument = null;
      _posts = [];
      if (!_isSearching) _searchQuery = "";
      notifyListeners();
    } else {
      if (!_hasMore || _isLoadingMore) return;
      _isLoadingMore = true;
      notifyListeners();
    }

    try {
      final snapshot = await _service.getPostsQuery(
        limit: 10,
        startAfter: _lastDocument,
        sortByLikes: _currentCategory == PostCategory.hot,
      );

      if (snapshot.docs.length < 10) {
        _hasMore = false;
      }

      if (snapshot.docs.isNotEmpty) {
        _lastDocument = snapshot.docs.last;
        final newPosts = snapshot.docs.map((doc) {
          return Post.fromFirestore(doc.id, doc.data() as Map<String, dynamic>);
        }).toList();

        _posts.addAll(newPosts);
      }
    } catch (e) {
      debugPrint("Fetch posts error: $e");
    } finally {
      _isLoading = false;
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  // [수정] 이미지와 함께 게시글 추가하는 통합 로직
  Future<void> addPost(Post post, {List<File>? images}) async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. ID 선점
      final docRef = _service.getNewPostRef();
      final postId = docRef.id;

      // 2. 이미지 업로드 (있는 경우)
      List<String> uploadedUrls = [];
      if (images != null && images.isNotEmpty) {
        uploadedUrls = await _service.uploadPostImages(postId, images);
      }

      // 3. 최종 데이터 객체 생성
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

      // 4. Firestore 저장
      await _service.addPostWithId(postWithImages);

      // 목록 새로고침
      await fetchPosts(isRefresh: true);
    } catch (e) {
      debugPrint("Add post with images error: $e");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> performSearch(String query) async {
    if (query.isEmpty) {
      clearSearch();
      return;
    }

    _isSearching = true;
    _isLoading = true;
    _searchQuery = query;
    _searchResults = [];
    notifyListeners();

    try {
      _searchResults = await _service.searchPosts(query);
    } catch (e) {
      debugPrint("Search error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearSearch() {
    if (!_isSearching) return;
    _isSearching = false;
    _searchQuery = "";
    _searchResults = [];
    notifyListeners();
  }

  Future<void> deletePost(String postId) async {
    try {
      await _service.deletePost(postId);
      _posts.removeWhere((p) => p.id == postId);
      _searchResults.removeWhere((p) => p.id == postId);
      notifyListeners();
    } catch (e) {
      debugPrint("Delete post error: $e");
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