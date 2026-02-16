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

  final List<Map<String, dynamic>> _categories = [
    {'label': 'All', 'icon': Icons.map, 'value': 'All'},
    {'label': 'Cafe', 'icon': Icons.coffee, 'value': 'Cafe'},
    {'label': 'Store', 'icon': Icons.local_convenience_store, 'value': 'Store'},
    {'label': 'Eat', 'icon': Icons.restaurant, 'value': 'Restaurant'},
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
              label: Text(cat['label']),
              selected: isSelected,
              onSelected: (selected) => onCategorySelected(cat['value']),
              selectedColor: AppColors.knuRed,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
              ),
              checkmarkColor: Colors.white,
            ),
          );
        },
      ),
    );
  }
}