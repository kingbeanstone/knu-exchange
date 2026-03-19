import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../utils/app_colors.dart';
import '../../utils/link_utils.dart';
import '../community/image_viewer_screen.dart';

class NoticeDetailBody extends StatefulWidget {
  final String content;
  final List<String> imageUrls;

  const NoticeDetailBody({
    super.key,
    required this.content,
    required this.imageUrls,
  });

  @override
  State<NoticeDetailBody> createState() => _NoticeDetailBodyState();
}

class _NoticeDetailBodyState extends State<NoticeDetailBody> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 줄바꿈 정제
    final cleanContent = widget.content.replaceAll('\r\n', '\n');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 다중 이미지 슬라이더 (Instagram 스타일)
          if (widget.imageUrls.isNotEmpty) ...[
            Stack(
              alignment: Alignment.bottomCenter,
              children: [
                SizedBox(
                  height: 300,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: widget.imageUrls.length,
                    onPageChanged: (index) => setState(() => _currentPage = index),
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ImageViewerScreen(
                                  imageUrls: widget.imageUrls,
                                  initialIndex: index,
                                ),
                              ),
                            );
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: CachedNetworkImage(
                              imageUrl: widget.imageUrls[index],
                              width: double.infinity,
                              height: 300,
                              fit: BoxFit.cover,
                              placeholder: (_, __) => Container(color: Colors.grey[100]),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                if (widget.imageUrls.length > 1)
                  Positioned(
                    bottom: 12,
                    child: Row(
                      // [수정] MapAxisAlignment -> MainAxisAlignment 오타 수정
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        widget.imageUrls.length,
                            (index) => Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _currentPage == index
                                ? AppColors.knuRed
                                : Colors.white.withOpacity(0.6),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),
          ],

          // 공지 본문 텍스트 (Markdown 렌더링 및 하이퍼링크 활성화)
          MarkdownBody(
            data: cleanContent,
            selectable: true,
            onTapLink: (text, href, title) {
              if (href != null) {
                // LinkUtil을 사용하여 안전하게 링크 열기
                LinkUtil.launch(href);
              }
            },
            styleSheet: MarkdownStyleSheet(
              p: TextStyle(
                fontSize: 16,
                height: 1.7,
                color: Colors.black.withOpacity(0.8),
                letterSpacing: -0.2,
              ),
              strong: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
              listBullet: const TextStyle(color: AppColors.knuRed),
              // 하이퍼링크 스타일링: 밑줄 제거
              a: const TextStyle(
                color: Colors.blue,
                decoration: TextDecoration.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}