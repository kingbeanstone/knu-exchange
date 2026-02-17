import 'package:flutter/material.dart';
import '../models/menu_item.dart';
import 'menu_list_item.dart';

class CafeteriaMenuSection extends StatelessWidget {
  // 1. 기존 Map<String, String> 대신 MenuItem 리스트를 받도록 타입을 확정합니다./
  final List<MenuItem> menuData;

  const CafeteriaMenuSection({
    super.key,
    required this.menuData,
  });

  @override
  Widget build(BuildContext context) {
    // 데이터가 없을 경우 처리
    if (menuData.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 60, horizontal: 20),
          child: Column(
            children: [
              Icon(Icons.no_food_outlined, size: 48, color: Colors.grey),
              SizedBox(height: 12),
              Text(
                'No menu information available.',
                style: TextStyle(color: Colors.grey, fontSize: 15),
              ),
            ],
          ),
        ),
      );
    }

    // 2. 아침 -> 점심 -> 저녁 순서로 정렬하기 위한 맵 정의
    // (MenuItem.fromCsv에서 이미 toLowerCase() 처리가 되어 있으므로 소문자로 비교)
    final Map<String, int> mealOrder = {
      'breakfast': 0,
      'lunch': 1,
      'dinner': 2,
    };

    // 원본 데이터를 보존하며 정렬된 복사본 생성
    final List<MenuItem> sortedData = List<MenuItem>.from(menuData);

    sortedData.sort((a, b) {
      // mealOrder에 없는 값이 들어올 경우 가장 뒤로 보냅니다 (99)
      int orderA = mealOrder[a.meal] ?? 99;
      int orderB = mealOrder[b.meal] ?? 99;
      return orderA.compareTo(orderB);
    });

    // 3. ListView를 사용하여 메뉴 출력
    // CafeteriaScreen의 SingleChildScrollView 내부에서 쓰이므로 shrinkWrap 설정 유지
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sortedData.length,
      itemBuilder: (context, index) {
        final item = sortedData[index];

        // 메뉴 문자열을 콤마(,) 기준으로 나누어 리스트로 변환
        final List<String> foodList = item.menu
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();

        return MenuListItem(
          // 화면 표시용 라벨 (예: lunch -> LUNCH)
          mealTime: item.meal.toUpperCase(),
          foods: foodList,
        );
      },
    );
  }
}