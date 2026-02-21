import 'package:flutter/material.dart';
import '../../models/post.dart';
import '../../utils/app_colors.dart';

class CommunityCategoryFilter extends StatelessWidget {
  final PostCategory? selectedCategory;
  final Function(PostCategory?) onCategorySelected;

  const CommunityCategoryFilter({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  // 카테고리별 라벨, 아이콘, 벨류 정의
  final List<Map<String, dynamic>> _items = const [
    {'label': 'All', 'icon': Icons.apps, 'value': null},
    {'label': 'Question', 'icon': Icons.help_outline, 'value': PostCategory.question},
    {'label': 'Tip', 'icon': Icons.lightbulb_outline, 'value': PostCategory.tip},
    {'label': 'Market', 'icon': Icons.shopping_cart_outlined, 'value': PostCategory.market},
    {'label': 'Free', 'icon': Icons.chat_bubble_outline, 'value': PostCategory.free},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        itemCount: _items.length,
        itemBuilder: (context, index) {
          final item = _items[index];
          final isSelected = selectedCategory == item['value'];

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              showCheckmark: false,
              avatar: Icon(
                item['icon'],
                size: 16,
                color: isSelected ? Colors.white : AppColors.knuRed,
              ),
              label: Text(item['label']),
              selected: isSelected,
              onSelected: (_) => onCategorySelected(item['value']),
              selectedColor: AppColors.knuRed,
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? AppColors.knuRed : Colors.grey.shade300,
                ),
              ),
              elevation: 0,
              pressElevation: 0,
            ),
          );
        },
      ),
    );
  }
}