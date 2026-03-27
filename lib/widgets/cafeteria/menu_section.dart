import 'package:flutter/material.dart';
import '../../models/menu_item.dart';
import 'cafeteria_widgets.dart'; // CafeteriaMenuCard 사용

class CafeteriaMenuSection extends StatelessWidget {
  final List<MenuItem> menuData;

  const CafeteriaMenuSection({
    super.key,
    required this.menuData,
  });

  @override
  Widget build(BuildContext context) {
    if (menuData.isEmpty) {
      return _buildEmptyState();
    }

    // 시간 순서 정렬 (조식 -> 중식 -> 석식)
    final Map<String, int> mealOrder = {
      'breakfast': 0,
      'lunch': 1,
      'dinner': 2,
    };

    final List<MenuItem> sortedData = List<MenuItem>.from(menuData);
    sortedData.sort((a, b) {
      int orderA = mealOrder[a.meal.toLowerCase()] ?? 99;
      int orderB = mealOrder[b.meal.toLowerCase()] ?? 99;
      return orderA.compareTo(orderB);
    });

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sortedData.length,
      itemBuilder: (context, index) {
        return CafeteriaMenuCard(menu: sortedData[index]);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 40),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.restaurant_menu_rounded, size: 40, color: Colors.grey.shade300),
            ),
            const SizedBox(height: 16),
            const Text(
              'No menu information.',
              style: TextStyle(color: Colors.grey, fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}