import 'package:flutter/material.dart';

class CafeteriaScreen extends StatelessWidget {
  const CafeteriaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 탭 컨트롤러를 사용하여 식당 종류별로 화면을 나눕니다.
    return DefaultTabController(
      length: 3, // 탭 개수 (학생식당, 기숙사, 교직원)
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Cafeteria Menu'),
          backgroundColor: const Color(0xFFDD1829),
          foregroundColor: Colors.white,
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: 'Student'),
              Tab(text: 'Dormitory'),
              Tab(text: 'Staff'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            Center(child: Text('Student Cafeteria Menu Here')),
            Center(child: Text('Dormitory Cafeteria Menu Here')),
            Center(child: Text('Staff Cafeteria Menu Here')),
          ],
        ),
      ),
    );
  }
}