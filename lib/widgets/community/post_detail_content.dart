import 'package:flutter/material.dart';
import 'image_viewer_screen.dart'; // [추가] 이미지 뷰어 스크린 임포트

class PostDetailContent extends StatefulWidget {
  final String content;
  final List<String> imageUrls;

  const PostDetailContent({
    super.key,
    required this.content,
    this.imageUrls = const [],
  });

  @override
  State<PostDetailContent> createState() => _PostDetailContentState();
}

class _PostDetailContentState extends State<PostDetailContent> {
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 이미지가 있을 경우 슬라이더 표시
        if (widget.imageUrls.isNotEmpty) ...[
          const SizedBox(height: 16),
          Stack(
            children: [
              SizedBox(
                height: 300,
                child: PageView.builder(
                  itemCount: widget.imageUrls.length,
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                  },
                  itemBuilder: (context, index) {
                    // 이미지를 터치하면 전체 화면 뷰어로 이동
                    return GestureDetector(
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
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            widget.imageUrls[index],
                            fit: BoxFit.cover,
                            width: double.infinity,
                            // [수정] 화질 저하 문제를 해결하기 위해 cacheHeight 제한을 제거합니다.
                            // 이제 원본 해상도로 선명하게 렌더링됩니다.
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                height: 300,
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                        : null,
                                    strokeWidth: 2,
                                    color: Colors.grey[300],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              // 페이지 인디케이터
              if (widget.imageUrls.length > 1)
                Positioned(
                  right: 32,
                  bottom: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_currentPage + 1}/${widget.imageUrls.length}',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
            ],
          ),
        ],

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
          child: SelectionArea(
            child: Text(
              widget.content,
              style: TextStyle(
                fontSize: 17,
                height: 1.7,
                color: Colors.black.withOpacity(0.8),
                letterSpacing: -0.3,
              ),
            ),
          ),
        ),
      ],
    );
  }
}