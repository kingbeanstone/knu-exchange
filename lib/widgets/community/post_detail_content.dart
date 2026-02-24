import 'package:flutter/material.dart';

class PostDetailContent extends StatefulWidget {
  final String content;
  final List<String> imageUrls; // [추가]

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
        // [추가] 이미지가 있을 경우 슬라이더 표시
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
                        // 선택 사항: 이미지 전체 화면 보기 기능 추가 가능
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            widget.imageUrls[index],
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              // 페이지 인디케이터 (예: 1/3)
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