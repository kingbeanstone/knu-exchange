import 'package:flutter/material.dart';

// [중요] 각 탭의 화면들을 폴더 구조에 맞춰 import 합니다.
// 만약 빨간 줄이 뜨면 파일 위치가 실제와 다른 것이니 경로를 수정해야 합니다.
import 'home/home_screen.dart';
import 'cafeteria/cafeteria_screen.dart';
import 'community/community_screen.dart';
import 'favorite/favorite_screen.dart';
import 'settings/settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // 탭별 화면 리스트
  final List<Widget> _screens = [
    const HomeScreen(), // 0: 홈 (지도)
    const CafeteriaScreen(), // 1: 식당
    const CommunityScreen(), // 2: 커뮤니티
    const FavoriteScreen(), // 3: 즐겨찾기
    const SettingsScreen(), // 4: 설정
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // 탭 4개 이상일 때 필수
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: const Color(0xFFDD1829), // KNU Red
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.map), label: '홈'),
          BottomNavigationBarItem(
              icon: Icon(Icons.restaurant_menu), label: '식당'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: '커뮤니티'),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: '즐겨찾기'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: '설정'),
        ],
      ),
    );
  }
}