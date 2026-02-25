import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/post.dart';
import '../services/community_service.dart';
import 'community_action_mixin.dart'; // Mixin 파일 임포트

/// 게시글 목록 조회 및 상태 관리를 담당하는 메인 프로바이더입니다.
class CommunityProvider with ChangeNotifier, CommunityActionMixin {
  final CommunityService _service = CommunityService();

  // 목록 관련 상태
  List<Post> _posts = [];
  List<Post> _searchResults = [];
  String _searchQuery = "";
  PostCategory? _currentCategory;
  bool _isMyPostsOnly = false;

  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _isSearching = false;
  bool _hasMore = true;
  DocumentSnapshot? _lastDocument;

  // Getters
  List<Post> get posts => _posts;
  List<Post> get searchResults => _searchResults;
  String get searchQuery => _searchQuery;
  PostCategory? get currentCategory => _currentCategory;
  bool get isMyPostsOnly => _isMyPostsOnly;

  // Mixin의 액션 로딩과 통합된 로딩 상태
  bool get isLoading => _isLoading || isLoadingAction;
  bool get isLoadingMore => _isLoadingMore;
  bool get isSearching => _isSearching;
  bool get hasMore => _hasMore;

  CommunityProvider() {
    fetchPosts(isRefresh: true);
  }

  // 카테고리 필터 설정
  void setCategory(PostCategory? category) {
    _currentCategory = category;
    _isMyPostsOnly = false;
    fetchPosts(isRefresh: true);
  }

  // '내 글만 보기' 필터 설정
  void setMyPostsOnly(bool value, String? userId) {
    _isMyPostsOnly = value;
    _currentCategory = null;
    fetchPosts(isRefresh: true, userId: userId);
  }

  // 데이터 조회 (Read)
  Future<void> fetchPosts({bool isRefresh = false, String? userId}) async {
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
        authorId: _isMyPostsOnly ? userId : null,
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

  // 검색 로직
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

  // 믹스인 메서드 오버라이드 (로컬 데이터 동기화용)
  @override
  Future<void> deletePost(String postId) async {
    await super.deletePost(postId);
    _posts.removeWhere((p) => p.id == postId);
    _searchResults.removeWhere((p) => p.id == postId);
    notifyListeners();
  }
}