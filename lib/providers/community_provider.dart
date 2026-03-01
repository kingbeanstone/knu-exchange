import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/post.dart';
import '../services/community_service.dart';
import 'community_action_mixin.dart';

class CommunityProvider with ChangeNotifier, CommunityActionMixin {
  final CommunityService _service = CommunityService();

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

  List<Post> get posts => _posts;
  List<Post> get searchResults => _searchResults;
  String get searchQuery => _searchQuery;
  PostCategory? get currentCategory => _currentCategory;
  bool get isMyPostsOnly => _isMyPostsOnly;
  bool get isLoading => _isLoading || isLoadingAction;
  bool get isLoadingMore => _isLoadingMore;
  bool get isSearching => _isSearching;
  bool get hasMore => _hasMore;

  CommunityProvider() {
    fetchPosts(isRefresh: true);
  }

  Future<Post?> fetchPostById(String postId) async {
    try {
      final inMemory = _posts.cast<Post?>().firstWhere((p) => p?.id == postId, orElse: () => null);
      if (inMemory != null) return inMemory;

      final doc = await _service.getPostById(postId);
      if (doc.exists) {
        return Post.fromFirestore(doc.id, doc.data() as Map<String, dynamic>);
      }
    } catch (e) {
      debugPrint("Fetch post by id error: $e");
    }
    return null;
  }

  void setCategory(PostCategory? category) {
    _currentCategory = category;
    _isMyPostsOnly = false;
    fetchPosts(isRefresh: true);
  }

  void setMyPostsOnly(bool value, String? userId) {
    _isMyPostsOnly = value;
    _currentCategory = null;
    fetchPosts(isRefresh: true, userId: userId);
  }

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
      final bool isHot = _currentCategory == PostCategory.hot;

      final snapshot = await _service.getPostsQuery(
        // [수정] Hot 필터일 경우 상위 10개를 뽑기 위해 넉넉히 가져옵니다.
        limit: isHot ? 100 : 10,
        startAfter: _lastDocument,
        sortByLikes: isHot,
        authorId: _isMyPostsOnly ? userId : null,
        category: _currentCategory,
      );

      // Hot 필터는 상위 10개 고정 목록이므로 추가 페이징을 비활성화합니다.
      if (isHot || snapshot.docs.length < 10) {
        _hasMore = false;
      }

      if (snapshot.docs.isNotEmpty) {
        _lastDocument = snapshot.docs.last;
        final newPosts = snapshot.docs.map((doc) {
          return Post.fromFirestore(doc.id, doc.data() as Map<String, dynamic>);
        }).toList();

        if (isHot) {
          // [수정] 1주일 이내 글들 중 좋아요 순으로 내림차순 정렬 후 상위 10개만 추출
          newPosts.sort((a, b) => b.likes.compareTo(a.likes));
          _posts = newPosts.take(10).toList();
        } else {
          _posts.addAll(newPosts);
        }
      }
    } catch (e) {
      debugPrint("Fetch posts error: $e");
    } finally {
      _isLoading = false;
      _isLoadingMore = false;
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
      final searchPool = await _service.fetchPostsForSearch();

      final filtered = searchPool.where((post) {
        final title = post.title.toLowerCase();
        final search = query.toLowerCase();
        return title.contains(search);
      }).toList();

      _searchResults = filtered;
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

  @override
  Future<void> deletePost(String postId) async {
    await super.deletePost(postId);
    _posts.removeWhere((p) => p.id == postId);
    _searchResults.removeWhere((p) => p.id == postId);
    notifyListeners();
  }
}