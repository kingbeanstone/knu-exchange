import 'package:flutter/material.dart';
import '../../models/post.dart';
import '../../utils/app_colors.dart';

class CommunityCategoryFilter extends StatelessWidget {
  final PostCategory? selectedCategory;
  final bool isMyPostsSelected;
  final Function(PostCategory?) onCategorySelected;
  final Function(bool) onMyPostsSelected;

  const CommunityCategoryFilter({
    super.key,
    required this.selectedCategory,
    required this.isMyPostsSelected,
    required this.onCategorySelected,
    required this.onMyPostsSelected,
  });

  // [수정] Lounge -> General로 라벨 변경
  List<Map<String, dynamic>> get _row1Items => [
    {'label': 'All', 'icon': Icons.apps, 'value': 'all'},
    {'label': 'Hot', 'icon': Icons.local_fire_department, 'value': PostCategory.hot},
    {'label': 'General', 'icon': Icons.chat_bubble_outline, 'value': PostCategory.lounge},
    {'label': 'Food', 'icon': Icons.restaurant_menu, 'value': PostCategory.food},
  ];

  List<Map<String, dynamic>> get _row2Items => [
    {'label': 'My Posts', 'icon': Icons.person_pin, 'value': 'mine'},
    {'label': 'Question', 'icon': Icons.help_outline, 'value': PostCategory.question},
    {'label': 'Tip', 'icon': Icons.lightbulb_outline, 'value': PostCategory.tip},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          _buildFilterRow(_row1Items),
          const SizedBox(height: 4),
          _buildFilterRow(_row2Items),
        ],
      ),
    );
  }

  Widget _buildFilterRow(List<Map<String, dynamic>> items) {
    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];

          bool isSelected = false;
          if (item['value'] == 'all') {
            isSelected = selectedCategory == null && !isMyPostsSelected;
          } else if (item['value'] == 'mine') {
            isSelected = isMyPostsSelected;
          } else {
            isSelected = selectedCategory == item['value'] && !isMyPostsSelected;
          }

          final Color themeColor = item['value'] == PostCategory.hot
              ? Colors.orange
              : AppColors.knuRed;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              showCheckmark: false,
              avatar: Icon(
                item['icon'],
                size: 16,
                color: isSelected ? Colors.white : themeColor,
              ),
              label: Text(item['label']),
              selected: isSelected,
              onSelected: (_) {
                if (item['value'] == 'all') {
                  onCategorySelected(null);
                } else if (item['value'] == 'mine') {
                  onMyPostsSelected(true);
                } else {
                  onCategorySelected(item['value'] as PostCategory?);
                }
              },
              selectedColor: themeColor,
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
              labelPadding: const EdgeInsets.only(left: 0, right: 4),
              padding: const EdgeInsets.only(left: 4, right: 8, top: 0, bottom: 0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? themeColor : Colors.grey.shade300,
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