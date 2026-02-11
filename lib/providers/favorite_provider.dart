import 'package:flutter/material.dart';

class FavoriteProvider extends ChangeNotifier {
  // 즐겨찾기한 장소의 ID들을 저장 (중복 방지를 위해 Set 사용)
  final Set<String> _favoriteIds = {};

  Set<String> get favoriteIds => _favoriteIds;

  // 즐겨찾기 여부 확인
  bool isFavorite(String id) => _favoriteIds.contains(id);

  // 즐겨찾기 토글 기능
  void toggleFavorite(String id) {
    if (_favoriteIds.contains(id)) {
      _favoriteIds.remove(id);
    } else {
      _favoriteIds.add(id);
    }
    notifyListeners(); // UI를 새로고침하게 만드는 핵심 코드
  }
}