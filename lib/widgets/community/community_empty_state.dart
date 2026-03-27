import 'package:flutter/material.dart';

class CommunityEmptyState extends StatelessWidget {
  final bool isSearching;
  final bool isMyPostsOnly;

  const CommunityEmptyState({
    super.key,
    required this.isSearching,
    required this.isMyPostsOnly,
  });

  @override
  Widget build(BuildContext context) {
    String message = isSearching
        ? 'No matching results found.'
        : 'No posts yet.\nBe the first to share!';

    if (!isSearching && isMyPostsOnly) {
      message = "You haven't written any posts yet.";
    }

    // [수정] 공지사항의 Empty State와 디자인 통일 (아이콘 크기 및 폰트)
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSearching
                ? Icons.search_off
                : (isMyPostsOnly ? Icons.person_off : Icons.speaker_notes_off),
            size: 64,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}