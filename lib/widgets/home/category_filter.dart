import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

class CategoryFilter extends StatelessWidget {
  final String selectedCategory;
  final Function(String) onCategorySelected;

  CategoryFilter({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  // 이전의 풍부한 아이콘 구성을 다시 가져왔습니다.
  final List<Map<String, dynamic>> _categories = [
    {'label': 'All', 'icon': Icons.map, 'value': 'All'},
    {'label': 'Cafeteria', 'icon': Icons.restaurant, 'value': 'Restaurant'},
    {'label': 'Cafe', 'icon': Icons.coffee, 'value': 'Cafe'},
    {'label': 'Store', 'icon': Icons.local_convenience_store, 'value': 'Store'},
    {'label': 'Office', 'icon': Icons.account_balance, 'value': 'Admin'},
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final isSelected = selectedCategory == cat['value'];

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: FilterChip(
              // 체크마크 대신 아이콘 아바타를 사용하여 더 직관적입니다.
              showCheckmark: false,
              avatar: Icon(
                cat['icon'],
                size: 18,
                color: isSelected ? Colors.white : AppColors.knuRed,
              ),
              label: Text(cat['label']),
              selected: isSelected,
              onSelected: (selected) => onCategorySelected(cat['value']),

              // 색상 및 스타일 복구
              selectedColor: AppColors.knuRed,
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),

              // 둥근 모서리와 테두리 설정
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? AppColors.knuRed : Colors.grey.shade300,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}