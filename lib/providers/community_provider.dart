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

  // [추가] 차단 시 UI에서 즉시 글을 제거하는 함수 (Apple 가이드라인 준수)
  void removePostsByAuthor(String authorId) {
    _posts.removeWhere((post) => post.authorId == authorId);
    _searchResults.removeWhere((post) => post.authorId == authorId);
    notifyListeners();
  }

  void setCategory(PostCategory? category, {List<String>? blockedUsers}) {
    _currentCategory = category;
    _isMyPostsOnly = false;
    fetchPosts(isRefresh: true, blockedUsers: blockedUsers);
  }

  void setMyPostsOnly(bool value, String? userId, {List<String>? blockedUsers}) {
    _isMyPostsOnly = value;
    _currentCategory = null;
    fetchPosts(isRefresh: true, userId: userId, blockedUsers: blockedUsers);
  }

  // [수정] blockedUsers 매개변수를 추가하여 서버 데이터를 필터링합니다.
  Future<void> fetchPosts({bool isRefresh = false, String? userId, List<String>? blockedUsers}) async {
    if (_isSearching && !isRefresh) return;

    if (isRefresh) {
      // [핵심] 새로고침(Pull-to-refresh)일 때는 _isLoading을 true로 만들지 않습니다.
      // RefreshIndicator가 이미 빙글이를 돌리고 있기 때문입니다.
      _hasMore = true;
      _lastDocument = null;
      // _posts = []; // 여기서 리스트를 비우지 않아야 새로고침 중에도 기존 글이 보여서 자연스럽습니다.
    } else {
      // 처음 데이터를 가져올 때만 중앙 스피너를 보여줍니다.
      if (_posts.isEmpty) {
        _isLoading = true;
      } else {
        if (!_hasMore || _isLoadingMore) return;
        _isLoadingMore = true;
      }
    }
    notifyListeners();

    try {
      final bool isHot = _currentCategory == PostCategory.hot;
      final snapshot = await _service.getPostsQuery(
        limit: isHot ? 100 : 10,
        startAfter: _lastDocument,
        sortByLikes: isHot,
        authorId: _isMyPostsOnly ? userId : null,
        category: _currentCategory,
      );

      if (isHot || snapshot.docs.length < 10) {
        _hasMore = false;
      }

      if (snapshot.docs.isNotEmpty) {
        _lastDocument = snapshot.docs.last;
        final newPosts = snapshot.docs.map((doc) {
          return Post.fromFirestore(doc.id, doc.data() as Map<String, dynamic>);
        }).toList();

        final List<String> myBlockedList = blockedUsers ?? [];
        final filteredPosts = newPosts.where((post) => !myBlockedList.contains(post.authorId)).toList();

        if (isRefresh) {
          // [수정] 새로고침이면 기존 리스트를 새 데이터로 완전히 교체합니다.
          _posts = filteredPosts;
        } else {
          _posts.addAll(filteredPosts);
        }
      } else if (isRefresh) {
        // 데이터가 하나도 없을 경우 리스트를 비워줍니다.
        _posts = [];
      }
    } catch (e) {
      debugPrint("Fetch posts error: $e");
    } finally {
      _isLoading = false;
      _isLoadingMore = false;
      notifyListeners(); // 여기서 빙글이가 멈추게 됩니다.
    }
  }

  // [수정] 검색 시에도 차단 목록을 적용합니다.
  Future<void> performSearch(String query, {List<String>? blockedUsers}) async {
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
      final List<String> myBlockedList = blockedUsers ?? [];

      final filtered = searchPool.where((post) {
        final title = post.title.toLowerCase();
        final search = query.toLowerCase();
        final isMatch = title.contains(search);
        // 차단되지 않은 유저 조건 추가
        final isNotBlocked = !myBlockedList.contains(post.authorId);
        return isMatch && isNotBlocked;
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
  // [추가] 알림에서 클릭한 특정 게시글의 정보를 가져오는 메서드
  Future<Post?> fetchPostById(String postId) async {
    try {
      // 1. 현재 리스트에 이미 글이 있는지 확인
      final inMemory = _posts.cast<Post?>().firstWhere(
            (p) => p?.id == postId,
        orElse: () => null,
      );
      if (inMemory != null) return inMemory;

      // 2. 리스트에 없다면 서버(Service)에서 단일 게시글 정보를 가져옴
      final doc = await _service.getPostById(postId);
      if (doc.exists) {
        return Post.fromFirestore(doc.id, doc.data() as Map<String, dynamic>);
      }
    } catch (e) {
      debugPrint("Fetch post by id error: $e");
    }
    return null;
  }
}