import 'package:flutter/material.dart';
import '../../../models/post.dart';
import '../../../utils/app_colors.dart';
import '../../../screens/community/post_detail_screen.dart';

class PostCard extends StatelessWidget {
  final Post post;

  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PostDetailScreen(post: post),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.categoryLabel,
                          style: const TextStyle(
                            color: AppColors.knuRed,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          post.title,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          post.content,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.grey[700], fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  // [추가] 이미지가 있다면 첫 번째 이미지를 썸네일로 표시
                  if (post.imageUrls.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          post.imageUrls.first,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            width: 80,
                            height: 80,
                            color: Colors.grey[200],
                            child: const Icon(Icons.image_not_supported, color: Colors.grey),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.person_outline, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    post.author,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const Spacer(),
                  // [추가] 이미지 개수 표시 아이콘
                  if (post.imageUrls.isNotEmpty) ...[
                    const Icon(Icons.image_outlined, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text('${post.imageUrls.length}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(width: 12),
                  ],
                  Icon(Icons.favorite_border, size: 14, color: Colors.grey[400]),
                  const SizedBox(width: 4),
                  Text('${post.likes}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(width: 12),
                  Icon(Icons.chat_bubble_outline, size: 14, color: Colors.grey[400]),
                  const SizedBox(width: 4),
                  Text('${post.comments}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}