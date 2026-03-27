import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/notification_provider.dart';
import '../../utils/app_colors.dart';
import '../../screens/notification/notification_screen.dart';

class CommunityAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool isSearchMode;
  final TextEditingController? searchController;
  final VoidCallback onSearchToggle;
  final Function(String)? onSearchChanged;

  const CommunityAppBar({
    super.key,
    required this.title,
    required this.isSearchMode,
    this.searchController,
    required this.onSearchToggle,
    this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    final unreadCount = context.watch<NotificationProvider>().unreadCount;

    // 검색 모드일 때의 상단바 설정
    if (isSearchMode) {
      return AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: onSearchToggle,
        ),
        title: TextField(
          controller: searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search posts by title...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.grey, fontSize: 16),
          ),
          style: const TextStyle(fontSize: 16),
          onChanged: onSearchChanged,
          textInputAction: TextInputAction.search,
        ),
        actions: [
          if (searchController?.text.isNotEmpty ?? false)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                searchController?.clear();
                onSearchChanged?.call('');
              },
            ),
        ],
      );
    }

    // 기본 상단바 설정 (빨간색 배경)
    return AppBar(
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.normal,
          fontSize: 18,
        ),
      ),
      backgroundColor: AppColors.knuRed,
      foregroundColor: Colors.white,
      elevation: 0,
      // [수정] 제목을 중앙으로 정렬합니다.
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: onSearchToggle,
        ),
        Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_none),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const NotificationScreen()),
                );
              },
            ),
            if (unreadCount > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.yellow,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                  child: Text(
                    unreadCount > 9 ? '9+' : unreadCount.toString(),
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}