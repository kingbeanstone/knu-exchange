import 'dart:io';
import 'package:flutter/material.dart';

class PostImagePicker extends StatelessWidget {
  final List<File> selectedImages;
  final VoidCallback onPickImages;
  final Function(int) onRemoveImage;

  const PostImagePicker({
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
              "Photos (Max 10)",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(
              "${selectedImages.length}/10",
              style: const TextStyle(color: Colors.grey),
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
              // 첫 번째 아이템은 항상 '추가 버튼'
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

              final imageIndex = index - 1;
              return Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        selectedImages[imageIndex],
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 12,
                    child: InkWell(
                      onTap: () => onRemoveImage(imageIndex),
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
            },
          ),
        ),
      ],
    );
  }
}