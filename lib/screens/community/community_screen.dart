import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/app_colors.dart';
import '../../models/post.dart';
import '../../providers/community_provider.dart';
import '../../widgets/community/post_card.dart';
import '../../widgets/community/community_category_filter.dart'; // [추가] 신규 위젯 임포트
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
          // [수정] 분리된 카테고리 필터 위젯 적용
          CommunityCategoryFilter(
            selectedCategory: _selectedCategory,
            onCategorySelected: (category) {
              setState(() => _selectedCategory = category);
            },
          ),
          const Divider(height: 1), // 시각적 구분을 위한 구분선
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