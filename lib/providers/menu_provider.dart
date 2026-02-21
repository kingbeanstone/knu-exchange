import 'package:flutter/material.dart';
import '../models/menu_item.dart';
import '../services/menu_service.dart';

class MenuProvider with ChangeNotifier {
  final MenuService _service = MenuService();

  List<MenuItem> _allMenus = [];
  bool _isLoading = false;

  List<MenuItem> get allMenus => _allMenus;
  bool get isLoading => _isLoading;

  // 전체 메뉴 새로고침 (사용자가 탭을 누를 때 호출 가능)
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

  // 화면에서 특정 식당과 날짜로 필터링된 메뉴를 가져올 때 사용
  List<MenuItem> getFilteredMenu(String facilityId, String date) {
    return _allMenus.where((m) => m.facility == facilityId && m.date == date).toList();
  }
}