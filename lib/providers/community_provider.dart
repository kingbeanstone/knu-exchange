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

  // [통합 로딩 상태] Mixin의 액션 로딩과 연동
  bool get isLoading => _isLoading || isLoadingAction;
  bool get isLoadingMore => _isLoadingMore;
  bool get isSearching => _isSearching;
  bool get hasMore => _hasMore;

  CommunityProvider() {
    // [수정] 생성자에서 fetchPosts(isRefresh: true) 호출을 삭제합니다.
    // 이제 화면(Screen)에서 유저 정보가 준비된 후 호출할 것입니다.
  }

  // 알림 이동용 게시글 단일 조회
  Future<Post?> fetchPostById(String postId) async {
    try {
      final inMemory = _posts.cast<Post?>().firstWhere(
            (p) => p?.id == postId,
        orElse: () => null,
      );
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

  // 차단 시 즉시 UI 반영
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

  // [핵심] 'All' 탭 및 전체 탭의 무한 로딩을 방지하는 로드 로직
  Future<void> fetchPosts({bool isRefresh = false, String? userId, List<String>? blockedUsers}) async {
    if (_isSearching && !isRefresh) return;
    if (!isRefresh && (!_hasMore || _isLoading || _isLoadingMore)) return;

    if (isRefresh) {
      _hasMore = true;
      _lastDocument = null;
      // 새로고침 시에 이미 데이터가 있다면 isLoading 대신 isLoadingMore처럼 작동하게 함
      if (_posts.isEmpty) _isLoading = true;
      _isLoadingMore = false;
    } else {
      _isLoadingMore = true;
    }
    notifyListeners();

    try {
      final bool isHot = _currentCategory == PostCategory.hot;
      final snapshot = await _service.getPostsQuery(
        limit: 10,
        startAfter: _lastDocument,
        sortByLikes: isHot,
        authorId: _isMyPostsOnly ? userId : null,
        category: _currentCategory,
      );

      if (snapshot.docs.isEmpty) {
        _hasMore = false;
      } else {
        _hasMore = snapshot.docs.length == 10;
        _lastDocument = snapshot.docs.last;

        final newPosts = snapshot.docs.map((doc) {
          return Post.fromFirestore(doc.id, doc.data() as Map<String, dynamic>);
        }).toList();

        final List<String> myBlockedList = blockedUsers ?? [];
        final filteredPosts = newPosts.where((post) => !myBlockedList.contains(post.authorId)).toList();

        if (isRefresh) {
          _posts = filteredPosts;
        } else {
          _posts.addAll(filteredPosts);
        }

        // [핵심] 차단된 글로 인해 화면에 추가된 글이 하나도 없다면, 자동으로 다음 페이지 호출
        if (_hasMore && filteredPosts.isEmpty) {
          _isLoadingMore = false; // 재호출을 위해 잠시 해제
          await fetchPosts(isRefresh: false, userId: userId, blockedUsers: blockedUsers);
          return; // 재귀 호출이 끝난 후 다시 setLoading(false)를 타지 않게 리턴
        }
      }
    } catch (e) {
      debugPrint("Fetch posts error: $e");
      _hasMore = false;
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
    notifyListeners();

    try {
      final searchPool = await _service.fetchPostsForSearch();
      final List<String> myBlockedList = blockedUsers ?? [];
      final filtered = searchPool.where((post) {
        final title = post.title.toLowerCase();
        final search = query.toLowerCase();
        return title.contains(search) && !myBlockedList.contains(post.authorId);
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
}