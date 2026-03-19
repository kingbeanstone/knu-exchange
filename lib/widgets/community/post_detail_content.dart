import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart'; // ✅ 추가
import '../common/full_screen_gallery.dart'; // ✅ 수정: 공통 갤러리 임포트

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
                    return GestureDetector(
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
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Hero(
                          // ✅ 추가: Hero 애니메이션 적용
                          tag: widget.imageUrls[index],
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: CachedNetworkImage(
                              imageUrl: widget.imageUrls[index],
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: 300,
                              // ✅ 화질을 위해 memCacheWidth 등은 설정하지 않음
                              placeholder: (context, url) => Container(
                                color: Colors.grey[100],
                                child: const Center(
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              ),
                              errorWidget: (context, url, error) => const Icon(Icons.error),
                            ),
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
                      color: Colors.black.withValues(alpha: 0.6),
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
                color: Colors.black.withValues(alpha: 0.8),
                letterSpacing: -0.3,
              ),
            ),
          ),
        ),
      ],
    );
  }
}