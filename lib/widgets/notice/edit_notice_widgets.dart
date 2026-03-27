import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class EditNoticeInputLabel extends StatelessWidget {
  final String text;
  const EditNoticeInputLabel({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
          color: Colors.grey,
          letterSpacing: 1.0
      ),
    );
  }
}

class EditNoticeImageEditor extends StatelessWidget {
  final List<String> existingUrls;
  final List<File> newFiles;
  final VoidCallback onPickImages;
  final Function(int) onRemoveExisting;
  final Function(int) onRemoveNew;

  const EditNoticeImageEditor({
    super.key,
    required this.existingUrls,
    required this.newFiles,
    required this.onPickImages,
    required this.onRemoveExisting,
    required this.onRemoveNew,
  });

  @override
  Widget build(BuildContext context) {
    final totalCount = existingUrls.length + newFiles.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
                "Attachments",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87)
            ),
            Text(
                "$totalCount/10",
                style: const TextStyle(color: Colors.grey, fontSize: 12)
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
              if (index == 0) return _buildAddButton();

              final itemIdx = index - 1;

              // 1. 기존 업로드된 이미지 렌더링
              if (itemIdx < existingUrls.length) {
                return _buildPreview(
                  child: CachedNetworkImage(
                    imageUrl: existingUrls[itemIdx],
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(color: Colors.grey[100]),
                    errorWidget: (_, __, ___) => const Icon(Icons.error_outline),
                  ),
                  onRemove: () => onRemoveExisting(itemIdx),
                );
              }

              // 2. 새로 선택한 파일 이미지 렌더링
              final fileIdx = itemIdx - existingUrls.length;
              return _buildPreview(
                child: Image.file(newFiles[fileIdx], fit: BoxFit.cover),
                onRemove: () => onRemoveNew(fileIdx),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAddButton() {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: InkWell(
        onTap: onPickImages,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 100,
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: const Icon(Icons.add_a_photo_outlined, color: Colors.grey, size: 24),
        ),
      ),
    );
  }

  Widget _buildPreview({required Widget child, required VoidCallback onRemove}) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(width: 100, height: 100, child: child),
          ),
        ),
        Positioned(
          top: 4,
          right: 16,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
              child: const Icon(Icons.close, color: Colors.white, size: 12),
            ),
          ),
        ),
      ],
    );
  }
}