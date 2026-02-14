import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/app_colors.dart';
import '../../models/post.dart';
import '../../providers/community_provider.dart';
import '../../widgets/post_card.dart'; // 새로 만든 PostCard 임포트
import 'create_post_screen.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  PostCategory? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final communityProvider = Provider.of<CommunityProvider>(context);

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
                : RefreshIndicator(
              onRefresh: communityProvider.fetchPosts,
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: filteredPosts.length,
                // 분리된 PostCard 위젯 사용
                itemBuilder: (context, index) => PostCard(post: filteredPosts[index]),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
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
}