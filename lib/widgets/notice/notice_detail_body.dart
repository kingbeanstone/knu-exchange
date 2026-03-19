import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../utils/app_colors.dart';
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
  // 현재 페이지 인덱스를 관리하기 위한 컨트롤러
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lines = widget.content.replaceAll('\r\n', '\n').split('\n');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // [수정] 여러 장의 이미지가 있을 경우 가로 슬라이더(PageView)로 변경
          if (widget.imageUrls.isNotEmpty) ...[
            Stack(
              alignment: Alignment.bottomCenter,
              children: [
                SizedBox(
                  height: 300, // 슬라이더 영역 높이 지정
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: widget.imageUrls.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      final url = widget.imageUrls[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: GestureDetector(
                          onTap: () {
                            // 이미지 터치 시 뷰어 실행 (현재 인덱스 전달)
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
                              imageUrl: url,
                              width: double.infinity,
                              height: 300,
                              fit: BoxFit.cover, // 슬라이더 영역을 꽉 채우도록 설정
                              placeholder: (context, url) => Container(
                                color: Colors.grey[100],
                                child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                              ),
                              errorWidget: (context, url, error) => const SizedBox.shrink(),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // [추가] 인디케이터 (점) 표시 영역
                if (widget.imageUrls.length > 1)
                  Positioned(
                    bottom: 12,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        widget.imageUrls.length,
                            (index) => Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            // 현재 활성화된 페이지는 KNU RED, 나머지는 반투명 화이트
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
            const SizedBox(height: 24), // 슬라이더와 텍스트 사이 간격
          ],

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