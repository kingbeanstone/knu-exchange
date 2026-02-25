import 'dart:io';
import 'package:flutter/material.dart';

class PostImagePicker extends StatelessWidget {
  final List<String> existingUrls; // 기존 업로드된 이미지들
  final List<File> selectedImages; // 새로 선택한 이미지들
  final VoidCallback onPickImages;
  final Function(int) onRemoveExisting;
  final Function(int) onRemoveNew;

  const PostImagePicker({
    super.key,
    this.existingUrls = const [],
    required this.selectedImages,
    required this.onPickImages,
    required this.onRemoveExisting,
    required this.onRemoveNew,
  });

  @override
  Widget build(BuildContext context) {
    final int totalCount = existingUrls.length + selectedImages.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Photos (Max 10)",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(
              "$totalCount/10",
              style: TextStyle(
                color: totalCount >= 10 ? Colors.red : Colors.grey,
                fontWeight: totalCount >= 10 ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            // 추가 버튼(1) + 기존 이미지들 + 새 이미지들
            itemCount: 1 + existingUrls.length + selectedImages.length,
            itemBuilder: (context, index) {
              // 1. 추가 버튼
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: InkWell(
                    onTap: totalCount < 10 ? onPickImages : null,
                    child: Container(
                      width: 100,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Icon(
                        Icons.add_a_photo_outlined,
                        color: totalCount < 10 ? Colors.grey : Colors.grey[300],
                      ),
                    ),
                  ),
                );
              }

              // 2. 기존 이미지 URL 렌더링
              if (index <= existingUrls.length) {
                final urlIndex = index - 1;
                return _buildImageItem(
                  image: Image.network(existingUrls[urlIndex], fit: BoxFit.cover),
                  onRemove: () => onRemoveExisting(urlIndex),
                  isExisting: true,
                );
              }

              // 3. 새로 선택한 파일 렌더링
              final fileIndex = index - 1 - existingUrls.length;
              return _buildImageItem(
                image: Image.file(selectedImages[fileIndex], fit: BoxFit.cover),
                onRemove: () => onRemoveNew(fileIndex),
                isExisting: false,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildImageItem({required Widget image, required VoidCallback onRemove, required bool isExisting}) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 100,
              height: 100,
              child: image,
            ),
          ),
        ),
        // 기존 이미지인 경우 표시해주는 배지 (선택 사항)
        if (isExisting)
          Positioned(
            bottom: 4,
            left: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                "SAVED",
                style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        Positioned(
          top: 4,
          right: 12,
          child: InkWell(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 16),
            ),
          ),
        ),
      ],
    );
  }
}