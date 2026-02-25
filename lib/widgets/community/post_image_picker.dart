import 'dart:io';
import 'package:flutter/material.dart';

class PostImagePicker extends StatelessWidget {
  final List<String> existingUrls; // 수정 시 기존 이미지
  final List<File> selectedImages; // 새로 선택한 이미지
  final VoidCallback onPickImages;
  final Function(int) onRemoveExisting; // 기존 이미지 삭제 콜백
  final Function(int) onRemoveNew;      // 새 이미지 삭제 콜백

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
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: totalCount + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: InkWell(
                    onTap: onPickImages,
                    child: Container(
                      width: 100,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: const Icon(Icons.add_a_photo_outlined, color: Colors.grey),
                    ),
                  ),
                );
              }

              final itemIndex = index - 1;

              // 기존 업로드된 이미지 렌더링
              if (itemIndex < existingUrls.length) {
                return _buildImageItem(
                  child: Image.network(existingUrls[itemIndex], fit: BoxFit.cover),
                  onRemove: () => onRemoveExisting(itemIndex),
                );
              }

              // 새로 선택한 파일 이미지 렌더링
              final fileIndex = itemIndex - existingUrls.length;
              return _buildImageItem(
                child: Image.file(selectedImages[fileIndex], fit: BoxFit.cover),
                onRemove: () => onRemoveNew(fileIndex),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildImageItem({required Widget child, required VoidCallback onRemove}) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 100,
              height: 100,
              child: child,
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