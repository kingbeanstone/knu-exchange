import 'package:flutter/material.dart';
import '../services/favorite_service.dart';

class FavoriteProvider extends ChangeNotifier {
  final FavoriteService _service = FavoriteService();
  final Set<String> _favoriteIds = {};
  String? _currentUserId;
  bool _isLoading = false;

  Set<String> get favoriteIds => _favoriteIds;
  bool get isLoading => _isLoading;

  // ProxyProvider에 의해 호출되어 사용자의 UID 상태를 동기화합니다.
  void updateUserId(String? userId) {
    // 사용자 ID가 실제로 바뀌었을 때만 로직 실행
    if (_currentUserId != userId) {
      _currentUserId = userId;

      if (userId != null) {
        // 로그인 시: 이전 데이터 삭제 후 새 사용자 데이터 로드
        _favoriteIds.clear();
        fetchFavorites();
      } else {
        // 로그아웃 시: 데이터 즉시 삭제
        _favoriteIds.clear();
        notifyListeners();
      }
    }
  }

  // Firestore에서 즐겨찾기 목록을 비동기로 가져옵니다.
  Future<void> fetchFavorites() async {
    if (_currentUserId == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final remoteIds = await _service.getFavorites(_currentUserId!);
      _favoriteIds.clear();
      _favoriteIds.addAll(remoteIds);
    } catch (e) {
      debugPrint("Fetch favorites error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool isFavorite(String id) => _favoriteIds.contains(id);

  // 즐겨찾기 토글 (낙관적 업데이트: UI 먼저 반영 후 서버 통신)
  Future<void> toggleFavorite(String id) async {
    if (_currentUserId == null) return;

    final isCurrentlyFav = _favoriteIds.contains(id);

    // 1. UI 즉시 반영
    if (isCurrentlyFav) {
      _favoriteIds.remove(id);
    } else {
      _favoriteIds.add(id);
    }
    notifyListeners();

    try {
      // 2. 서버 데이터 업데이트 요청
      await _service.toggleFavorite(_currentUserId!, id, !isCurrentlyFav);
    } catch (e) {
      // 3. 에러 발생 시 원래 상태로 롤백
      if (isCurrentlyFav) {
        _favoriteIds.add(id);
      } else {
        _favoriteIds.remove(id);
      }
      notifyListeners();
      debugPrint("Toggle favorite error: $e");
    }
  }
}