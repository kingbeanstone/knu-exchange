import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../models/menu_item.dart';

/// 개별 메뉴 정보를 담은 카드 위젯
class CafeteriaMenuCard extends StatelessWidget {
  final MenuItem menu;

  const CafeteriaMenuCard({super.key, required this.menu});

  IconData _getMealIcon() {
    final meal = menu.meal.toLowerCase();
    if (meal.contains('break')) return Icons.wb_twilight_rounded;
    if (meal.contains('lunch')) return Icons.wb_sunny_rounded;
    if (meal.contains('dinner')) return Icons.nights_stay_rounded;
    return Icons.restaurant_rounded;
  }

  Color _getMealColor() {
    final meal = menu.meal.toLowerCase();
    if (meal.contains('break')) return Colors.orange;
    if (meal.contains('lunch')) return Colors.blue;
    if (meal.contains('dinner')) return Colors.indigo;
    return AppColors.knuRed;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: _getMealColor().withOpacity(0.05),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Icon(_getMealIcon(), size: 18, color: _getMealColor()),
                const SizedBox(width: 8),
                Text(
                  menu.meal.toUpperCase(),
                  style: TextStyle(
                    color: _getMealColor(),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              menu.menu.split(',').map((e) => e.trim()).join('\n'),
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.darkGrey,
                height: 1.6,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}