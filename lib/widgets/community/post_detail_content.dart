import 'package:flutter/material.dart';

class PostDetailContent extends StatelessWidget {
  final String content;

  const PostDetailContent({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
      child: SelectionArea(
        child: Text(
          content,
          style: TextStyle(
            fontSize: 17,
            height: 1.7,
            color: Colors.black.withValues(alpha: 0.8),
            letterSpacing: -0.3,
          ),
        ),
      ),
    );
  }
}