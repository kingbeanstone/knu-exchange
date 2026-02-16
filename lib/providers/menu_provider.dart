import 'package:flutter/material.dart';
import '../models/menu_item.dart';
import '../services/menu_service.dart';

class MenuProvider with ChangeNotifier {
  final MenuService _service = MenuService();

  List<MenuItem> _allMenus = [];
  bool _isLoading = false;

  List<MenuItem> get allMenus => _allMenus;
  bool get isLoading => _isLoading;

  // 메뉴 데이터 새로고침
  Future<void> refreshMenu() async {
    _isLoading = true;
    notifyListeners();

    try {
      _allMenus = await _service.fetchRemoteMenu();
    } catch (e) {
      debugPrint("Menu Provider Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 필터링 로직: 특정 식당, 특정 날짜의 메뉴만 반환
  List<MenuItem> getFilteredMenu(String facilityId, String date) {
    return _allMenus.where((m) => m.facility == facilityId && m.date == date).toList();
  }
}