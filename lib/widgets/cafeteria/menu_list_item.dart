import 'package:flutter/material.dart';

class MenuListItem extends StatelessWidget {
  final String mealTime; // 점심, 저녁
  final List<String> foods;

  const MenuListItem({super.key, required this.mealTime, required this.foods});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(mealTime, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(foods.join(', '), style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}