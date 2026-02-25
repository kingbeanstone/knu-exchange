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

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSearching
                ? Icons.search_off
                : (isMyPostsOnly ? Icons.person_off : Icons.speaker_notes_off),
            size: 60,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey, height: 1.5),
          ),
        ],
      ),
    );
  }
}