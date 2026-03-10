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

  // [추가] 내 리스트에서 특정 작성자의 글을 즉시 제거하는 함수
  // [중요] 화면에서 즉시 글을 지우는 핵심 함수
  void removePostsByAuthor(String authorId) {
    debugPrint("UI에서 제거할 작성자 ID: $authorId");

    // 1. 일반 게시글 리스트에서 제거
    _posts.removeWhere((post) => post.authorId == authorId);

    // 2. 검색 결과 리스트에서도 제거
    _searchResults.removeWhere((post) => post.authorId == authorId);

    // 3. UI 새로고침 트리거
    notifyListeners();
  }

  // [수정] fetchPosts 메서드에 blockedUsers 매개변수 추가
  Future<void> fetchPosts({bool isRefresh = false, String? userId, List<String>? blockedUsers}) async {
    if (_isSearching && !isRefresh) return;

    if (isRefresh) {
      _isLoading = true;
      _hasMore = true;
      _lastDocument = null;
      _posts = [];
      notifyListeners();
    } else {
      if (!_hasMore || _isLoadingMore) return;
      _isLoadingMore = true;
      notifyListeners();
    }

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
        final List<Post> fetchedPosts = snapshot.docs.map((doc) {
          return Post.fromFirestore(doc.id, doc.data() as Map<String, dynamic>);
        }).toList();

        // 1. [디버깅 추가] 현재 이 메서드에 전달된 차단 목록을 로그로 출력합니다.
        final List<String> myBlockedList = blockedUsers ?? [];
        debugPrint("📢 필터링 적용 중 - 차단 유저 수: ${myBlockedList.length}");
        debugPrint("📢 차단 유저 ID 리스트: $myBlockedList");

        // 2. [필터링 로직] 서버에서 가져온 글 중 차단된 ID가 포함되지 않은 것만 골라냅니다.
        final filteredPosts = fetchedPosts.where((post) {
          final isBlocked = myBlockedList.contains(post.authorId);
          if (isBlocked) debugPrint("🚫 차단된 게시글 필터링됨: ${post.title}");
          return !isBlocked;
        }).toList();

        if (isHot) {
          filteredPosts.sort((a, b) => b.likes.compareTo(a.likes));
          _posts = filteredPosts.take(10).toList();
        } else {
          _posts.addAll(filteredPosts);
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
        final isNotBlocked = !myBlockedList.contains(post.authorId);

        return isMatch && isNotBlocked;
      }).toList();

      _searchResults = filtered;
    } catch (e) {
      // [해결] catch 블록을 추가하여 문법 에러 해결
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