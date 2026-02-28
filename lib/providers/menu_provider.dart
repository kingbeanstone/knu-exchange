import 'package:flutter/material.dart';
import '../models/menu_item.dart';
import '../services/menu_service.dart';

class MenuProvider with ChangeNotifier {
  final MenuService _service = MenuService();

  List<MenuItem> _allMenus = [];
  bool _isLoading = false;

  List<MenuItem> get allMenus => _allMenus;
  bool get isLoading => _isLoading;

  /// 구글 드라이브(원격 CSV)에서 전체 메뉴 데이터를 새로고침합니다.
  Future<void> refreshMenu() async {
    _isLoading = true;
    notifyListeners();

    try {
      _allMenus = await _service.fetchRemoteMenu();
    } catch (e) {
      debugPrint("Menu refresh failed: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 특정 장소와 날짜로 필터링된 메뉴 목록을 반환합니다.
  List<MenuItem> getFilteredMenu(String facilityId, String date) {
    return _allMenus
        .where((m) => m.facility == facilityId && m.date == date)
        .toList();
  }
}