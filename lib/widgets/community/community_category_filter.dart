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

  List<Map<String, dynamic>> get _items => [
    {'label': 'All', 'icon': Icons.apps, 'value': 'all'},
    {'label': 'My Posts', 'icon': Icons.person_pin, 'value': 'mine'},
    {'label': 'Hot', 'icon': Icons.local_fire_department, 'value': PostCategory.hot},
    {'label': 'Free', 'icon': Icons.chat_bubble_outline, 'value': PostCategory.free},
    {'label': 'Question', 'icon': Icons.help_outline, 'value': PostCategory.question},
    {'label': 'Tip', 'icon': Icons.lightbulb_outline, 'value': PostCategory.tip},
    {'label': 'Market', 'icon': Icons.shopping_cart_outlined, 'value': PostCategory.market},
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

          bool isSelected = false;
          if (item['value'] == 'all') {
            isSelected = selectedCategory == null && !isMyPostsSelected;
          } else if (item['value'] == 'mine') {
            isSelected = isMyPostsSelected;
          } else {
            isSelected = selectedCategory == item['value'] && !isMyPostsSelected;
          }

          final Color themeColor = item['value'] == PostCategory.hot ? Colors.orange : AppColors.knuRed;

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