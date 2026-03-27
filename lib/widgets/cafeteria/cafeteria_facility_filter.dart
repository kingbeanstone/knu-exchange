import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

/// 2줄 이상의 멀티 라인 방식의 식당 필터 (Wrap 사용)
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 8,      // 가로 간격
        runSpacing: 0,   // 줄 간격
        alignment: WrapAlignment.start,
        children: facilities.entries.map((entry) {
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
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
          );
        }).toList(),
      ),
    );
  }
}