import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/app_colors.dart';
import '../../models/post.dart';
import '../../providers/community_provider.dart';
import 'post_detail_screen.dart';
import 'create_post_screen.dart'; // 글쓰기 화면

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  PostCategory? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    // CommunityProvider 구독
    final communityProvider = Provider.of<CommunityProvider>(context);

    // 카테고리 필터링 (메모리 내 수행)
    final filteredPosts = _selectedCategory == null
        ? communityProvider.posts
        : communityProvider.posts.where((p) => p.category == _selectedCategory).toList();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('KNU Community'),
        backgroundColor: AppColors.knuRed,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildCategoryBar(),
          Expanded(
            child: communityProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredPosts.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: filteredPosts.length,
              itemBuilder: (context, index) => _buildPostCard(filteredPosts[index]),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 글쓰기 화면으로 이동
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreatePostScreen()),
          );
        },
        backgroundColor: AppColors.knuRed,
        child: const Icon(Icons.edit, color: Colors.white),
      ),
    );
  }

  Widget _buildCategoryBar() {
    return Container(
      color: Colors.white,
      height: 60,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        children: [
          _categoryChip('All', null),
          _categoryChip('Question', PostCategory.question),
          _categoryChip('Tip', PostCategory.tip),
          _categoryChip('Market', PostCategory.market),
          _categoryChip('Free', PostCategory.free),
        ],
      ),
    );
  }

  Widget _categoryChip(String label, PostCategory? category) {
    final isSelected = _selectedCategory == category;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) => setState(() => _selectedCategory = category),
        selectedColor: AppColors.knuRed,
        labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87),
        showCheckmark: false,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.speaker_notes_off, size: 60, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text(
            'No posts yet.\nBe the first to share!',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildPostCard(Post post) {
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
              Text(
                  post.categoryLabel,
                  style: const TextStyle(
                    color: AppColors.knuRed,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  )
              ),
              const SizedBox(height: 8),
              Text(
                  post.title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
              ),
              const SizedBox(height: 6),
              Text(
                post.content,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey[700], fontSize: 14),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.person_outline, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(post.author, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  const Spacer(),
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