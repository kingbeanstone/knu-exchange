import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../utils/app_colors.dart';
import '../../models/menu_item.dart';

/// 프리미엄 디자인이 적용된 날짜 선택기
class CafeteriaDateSelector extends StatelessWidget {
  final DateTime selectedDate;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  const CafeteriaDateSelector({
    super.key,
    required this.selectedDate,
    required this.onPrev,
    required this.onNext,
  });

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: onPrev,
            icon: const Icon(Icons.chevron_left_rounded, color: AppColors.knuRed, size: 28),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_isToday(selectedDate))
                Container(
                  // [수정] EdgeInsets.bottom(4) 대신 EdgeInsets.only(bottom: 4)를 사용합니다.
                  margin: const EdgeInsets.only(bottom: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.knuRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'TODAY',
                    style: TextStyle(
                      color: AppColors.knuRed,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              Text(
                DateFormat('yyyy.MM.dd (EEE)').format(selectedDate),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkGrey,
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: onNext,
            icon: const Icon(Icons.chevron_right_rounded, color: AppColors.knuRed, size: 28),
          ),
        ],
      ),
    );
  }
}

/// 가로 스크롤 방식의 식당 필터
class CafeteriaFacilityFilter extends StatelessWidget {
  final String selectedId;
  final Map<String, String> facilities;
  final Function(String) onSelected;

  const CafeteriaFacilityFilter({
    super.key,
    required this.selectedId,
    required this.facilities,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: facilities.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final entry = facilities.entries.elementAt(index);
          final isSelected = entry.key == selectedId;

          return ChoiceChip(
            label: Text(entry.value),
            selected: isSelected,
            onSelected: (_) => onSelected(entry.key),
            selectedColor: AppColors.knuRed,
            backgroundColor: Colors.white,
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : Colors.grey.shade600,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 13,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
              side: BorderSide(
                color: isSelected ? AppColors.knuRed : Colors.grey.shade200,
              ),
            ),
            showCheckmark: false,
            elevation: 0,
            pressElevation: 0,
          );
        },
      ),
    );
  }
}

/// 메뉴 정보를 담은 카드 위젯
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