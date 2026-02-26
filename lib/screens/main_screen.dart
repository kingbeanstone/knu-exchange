import 'package:flutter/material.dart';
import 'package:knu_ex/screens/notice/notice_screen.dart';

// [중요] 각 탭의 화면들을 폴더 구조에 맞춰 import 합니다.
// 만약 빨간 줄이 뜨면 파일 위치가 실제와 다른 것이니 경로를 수정해야 합니다.
import 'home/home_screen.dart';
import 'cafeteria/cafeteria_screen.dart';
import 'community/community_screen.dart';
import 'settings/settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  String? _initialCafeteriaId;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void goToCafeteria(String facilityId) {
    setState(() {
      _selectedIndex = 1; // 👈 Cafeteria 탭 index (확인 필요)
      _initialCafeteriaId = facilityId;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          HomeScreen(
            onGoToCafeteria: goToCafeteria,
          ),
          CafeteriaScreen(
            initialFacilityId: _initialCafeteriaId,
          ),
          CommunityScreen(),
          NoticeScreen(),
          SettingsScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: const Color(0xFFDD1829),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.restaurant_menu), label: 'Cafeteria'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Community'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notice'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Setting'),
        ],
      ),
    );
  }
}