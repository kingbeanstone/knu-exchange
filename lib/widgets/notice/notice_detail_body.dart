import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../utils/app_colors.dart';
import '../../utils/link_utils.dart';
import '../common/full_screen_gallery.dart';

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
    // 1. 줄바꿈 데이터 정제 강화
    // 서버에서 넘어온 문자열 내의 '\\n'(텍스트)을 실제 '\n'(줄바꿈)으로 치환합니다.
    final cleanContent = widget.content
        .replaceAll(r'\n', '\n')     // 이스케이프된 역슬래시+n 처리
        .replaceAll('\r\n', '\n')   // 윈도우 스타일 줄바꿈 통합
        .replaceAll('\n\n', '\n\u200B\n') // ✅ 핵심: 모든 줄바꿈 뒤에 제로 너비 공간(Zero-width space) 추가
        .trim();                    // 앞뒤 불필요한 공백 제거

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
                            // ✅ 수정: 삼성 스타일 갤러리로 이동
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FullScreenGallery(
                                  photos: widget.imageUrls,
                                  initialIndex: index,
                                ),
                              ),
                            );
                          },
                          // ✅ 추가: Hero 애니메이션 적용
                          child: Hero(
                            tag: widget.imageUrls[index],
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: CachedNetworkImage(
                                imageUrl: widget.imageUrls[index],
                                width: double.infinity,
                                height: 300,
                                fit: BoxFit.cover,
                                placeholder: (_, _) => Container(color: Colors.grey[100]),
                              ),
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
                                : Colors.white.withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),
          ],

          // 공지 본문 텍스트
          MarkdownBody(
            data: cleanContent,
            softLineBreak: true,
            selectable: true,
            onTapLink: (text, href, title) {
              if (href != null) LinkUtil.launch(href);
            },
            // 3. 스타일시트 설정 방식 변경 (기본 테마 상속)
            styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
              p: TextStyle(
                fontSize: 16,
                height: 1.6, // 줄 간격(Line height) 조정
                color: Colors.black.withValues(alpha: 0.8),
                letterSpacing: -0.2,
              ),
              // 4. 단락과 단락 사이의 간격 명시 (매우 중요)
              blockSpacing: 10,
              listBullet: const TextStyle(color: Colors.black),
              strong: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
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