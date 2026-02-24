import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/app_colors.dart';
import '../../models/post.dart';
import '../../providers/community_provider.dart';
import '../../widgets/community/post_card.dart';
import '../../widgets/community/community_category_filter.dart';
import '../../widgets/community/community_search_bar.dart'; // [추가] 검색바 임포트
import 'create_post_screen.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  PostCategory? _selectedCategory;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final provider = Provider.of<CommunityProvider>(context, listen: false);
    // 검색 중이 아닐 때만 무한 스크롤 작동
    if (!provider.isSearching && _scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (provider.hasMore && !provider.isLoadingMore) {
        provider.fetchPosts();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final communityProvider = Provider.of<CommunityProvider>(context);

    // 검색 중이면 검색 결과를, 아니면 필터링된 게시글 목록을 사용합니다.
    final List<Post> displayPosts;
    if (communityProvider.isSearching) {
      displayPosts = _selectedCategory == null
          ? communityProvider.searchResults
          : communityProvider.searchResults.where((p) => p.category == _selectedCategory).toList();
    } else {
      displayPosts = _selectedCategory == null
          ? communityProvider.posts
          : communityProvider.posts.where((p) => p.category == _selectedCategory).toList();
    }

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
          // [추가] 검색바 배치
          CommunitySearchBar(
            onSearch: (query) => communityProvider.performSearch(query),
            onClear: () => communityProvider.clearSearch(),
          ),

          CommunityCategoryFilter(
            selectedCategory: _selectedCategory,
            onCategorySelected: (category) {
              setState(() => _selectedCategory = category);
            },
          ),
          const Divider(height: 1),

          Expanded(
            child: communityProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : displayPosts.isEmpty
                ? _buildEmptyState(communityProvider.isSearching)
                : RefreshIndicator(
              onRefresh: () => communityProvider.fetchPosts(isRefresh: true),
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(12),
                // 검색 중이 아닐 때만 하단 로딩 바 노출
                itemCount: displayPosts.length + (!communityProvider.isSearching && communityProvider.hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index < displayPosts.length) {
                    return PostCard(post: displayPosts[index]);
                  } else {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                },
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

  Widget _buildEmptyState(bool isSearching) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
              isSearching ? Icons.search_off : Icons.speaker_notes_off,
              size: 60,
              color: Colors.grey[300]
          ),
          const SizedBox(height: 16),
          Text(
            isSearching
                ? 'No matching results found.'
                : 'No posts yet.\nBe the first to share!',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}