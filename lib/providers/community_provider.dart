import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/post.dart';
import '../services/community_service.dart';

class CommunityProvider with ChangeNotifier {
  final CommunityService _service = CommunityService();

  List<Post> _posts = [];
  List<Post> _searchResults = []; // 검색 결과 리스트
  String _searchQuery = "";      // 현재 검색어
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _isSearching = false;     // 검색 모드 활성화 여부
  bool _hasMore = true;
  DocumentSnapshot? _lastDocument;

  List<Post> get posts => _posts;
  List<Post> get searchResults => _searchResults;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get isSearching => _isSearching;
  bool get hasMore => _hasMore;

  CommunityProvider() {
    fetchPosts(isRefresh: true);
  }

  /// 🔄 데이터 가져오기 (새로고침 또는 초기 로드)
  Future<void> fetchPosts({bool isRefresh = false}) async {
    // 검색 중일 때 새로고침이 아니라면 일반 페이징 로드를 차단합니다.
    if (_isSearching && !isRefresh) return;

    if (isRefresh) {
      _isLoading = true;
      _hasMore = true;
      _lastDocument = null;
      _posts = [];
      _isSearching = false; // 새로고침 시 검색 모드 강제 해제
      _searchQuery = "";
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

  /// 🔍 검색 실행 (제목 기반 시작 단어 검색)
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

  /// ❌ 검색 초기화 및 원래 목록 복귀
  void clearSearch() {
    if (!_isSearching) return; // 이미 검색 중이 아니면 실행 안 함

    _isSearching = false;
    _searchQuery = "";
    _searchResults = [];
    notifyListeners(); // 상태 변경 알림 -> UI가 자동으로 _posts 리스트를 보여줌
  }

  Future<void> addPost(Post post) async {
    await _service.addPost(post);
    fetchPosts(isRefresh: true);
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
      // 참고: 실시간 스트림이 아니므로 필요시 로컬 상태를 수동으로 업데이트하는 로직을 추가할 수 있습니다.
    } catch (e) {
      debugPrint("Toggle like error: $e");
    }
  }
}