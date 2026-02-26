import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../utils/app_colors.dart';

class NoticeDetailBody extends StatelessWidget {
  final String content;

  const NoticeDetailBody({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    // 줄바꿈 처리 로직
    final lines = content.replaceAll('\r\n', '\n').split('\n');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final line in lines) ...[
            if (line.trim().isEmpty)
              const SizedBox(height: 16)
            else
              MarkdownBody(
                data: line,
                softLineBreak: true,
                styleSheet: MarkdownStyleSheet(
                  p: TextStyle(
                    fontSize: 16,
                    height: 1.7,
                    color: Colors.black.withOpacity(0.8),
                    letterSpacing: -0.2,
                  ),
                  strong: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  listBullet: const TextStyle(color: AppColors.knuRed),
                ),
              ),
          ],
        ],
      ),
    );
  }
}