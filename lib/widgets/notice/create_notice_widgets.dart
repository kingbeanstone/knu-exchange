import 'dart:io';
import 'package:flutter/material.dart';

/// 공지 등록 화면의 섹션 라벨
class CreateNoticeInputLabel extends StatelessWidget {
  final String text;
  const CreateNoticeInputLabel({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 12,
        color: Colors.grey,
        letterSpacing: 1.0,
      ),
    );
  }
}

/// 공지 등록 화면용 다중 이미지 선택 위젯 (파라미터 이름 수정 완료)
class CreateNoticeImagePicker extends StatelessWidget {
  final List<File> selectedImages; // s 추가됨
  final VoidCallback onPickImages; // s 추가됨
  final Function(int) onRemoveImage;

  const CreateNoticeImagePicker({
    super.key,
    required this.selectedImages,
    required this.onPickImages,
    required this.onRemoveImage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Photos",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87),
            ),
            Text(
              "${selectedImages.length}/10",
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: selectedImages.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return _buildAddButton();
              }
              final fileIndex = index - 1;
              return _buildImagePreview(selectedImages[fileIndex], fileIndex);
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_a_photo_outlined, color: Colors.grey[400], size: 28),
              const SizedBox(height: 4),
              Text("Add", style: TextStyle(color: Colors.grey[400], fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePreview(File file, int index) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              file,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: 4,
          right: 16,
          child: GestureDetector(
            onTap: () => onRemoveImage(index),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
              child: const Icon(Icons.close, color: Colors.white, size: 14),
            ),
          ),
        ),
      ],
    );
  }
}