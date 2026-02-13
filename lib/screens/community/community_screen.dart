import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/app_colors.dart';
import '../../models/post.dart';
import '../../providers/community_provider.dart';
import '../../providers/auth_provider.dart';
import '../settings/login_screen.dart';
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
    final community = Provider.of<CommunityProvider>(context);
    final auth = Provider.of<AuthProvider>(context);

    // 카테고리 필터링 (메모리 내 필터링 - 규칙 준수)
    final filteredPosts = _selectedCategory == null
        ? community.posts
        : community.posts.where((p) => p.category == _selectedCategory).toList();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('KNU Community'),
        backgroundColor: AppColors.knuRed,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildCategoryBar(),
          Expanded(
            child: community.isLoading
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
          if (auth.isAuthenticated) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CreatePostScreen()),
            );
          } else {
            _showLoginDialog();
          }
        },
        backgroundColor: AppColors.knuRed,
        child: const Icon(Icons.edit, color: Colors.white),
      ),
    );
  }

  void _showLoginDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Login Required'),
        content: const Text('You need to log in to write a post.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
            },
            child: const Text('Login'),
          ),
        ],
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
          const Text('No posts found in this category.', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildPostCard(Post post) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          // TODO: 게시글 상세 보기 구현
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.knuRed.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      post.categoryLabel.toUpperCase(),
                      style: const TextStyle(color: AppColors.knuRed, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Text(
                    '${post.createdAt.month}/${post.createdAt.day} ${post.createdAt.hour}:${post.createdAt.minute.toString().padLeft(2, '0')}',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                post.title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                post.content,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey[700], fontSize: 14),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.person_outline, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(post.author, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                  const Spacer(),
                  const Icon(Icons.favorite_border, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text('${post.likes}', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                  const SizedBox(width: 12),
                  const Icon(Icons.chat_bubble_outline, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text('${post.comments}', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}