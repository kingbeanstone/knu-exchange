import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/app_colors.dart';
import '../../models/post.dart';
import '../../providers/community_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/community/post_card.dart';
import '../../widgets/community/community_category_filter.dart';
import '../../widgets/community/community_search_bar.dart';
import 'create_post_screen.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
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
    final auth = Provider.of<AuthProvider>(context, listen: false);

    if (!provider.isSearching && _scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (provider.hasMore && !provider.isLoadingMore) {
        provider.fetchPosts(userId: auth.user?.uid);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final communityProvider = Provider.of<CommunityProvider>(context);
    final auth = Provider.of<AuthProvider>(context);

    final selectedCategory = communityProvider.currentCategory;
    final isMyPostsOnly = communityProvider.isMyPostsOnly;

    final List<Post> displayPosts;
    if (communityProvider.isSearching) {
      displayPosts = selectedCategory == null
          ? communityProvider.searchResults
          : communityProvider.searchResults.where((p) => p.category == selectedCategory).toList();
    } else {
      displayPosts = communityProvider.posts;
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
          CommunitySearchBar(
            onSearch: (query) => communityProvider.performSearch(query),
            onClear: () => communityProvider.clearSearch(),
          ),

          CommunityCategoryFilter(
            selectedCategory: selectedCategory,
            isMyPostsSelected: isMyPostsOnly,
            onCategorySelected: (category) {
              communityProvider.setCategory(category);
            },
            onMyPostsSelected: (isActive) {
              communityProvider.setMyPostsOnly(isActive, auth.user?.uid);
            },
          ),
          const Divider(height: 1),

          Expanded(
            child: communityProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : displayPosts.isEmpty
                ? _buildEmptyState(communityProvider.isSearching, isMyPostsOnly)
                : RefreshIndicator(
              onRefresh: () => communityProvider.fetchPosts(
                isRefresh: true,
                userId: auth.user?.uid,
              ),
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(12),
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

  Widget _buildEmptyState(bool isSearching, bool isMyPostsOnly) {
    String message = isSearching
        ? 'No matching results found.'
        : 'No posts yet.\nBe the first to share!';

    if (!isSearching && isMyPostsOnly) {
      message = "You haven't written any posts yet.";
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
              isSearching ? Icons.search_off : (isMyPostsOnly ? Icons.person_off : Icons.speaker_notes_off),
              size: 60,
              color: Colors.grey[300]
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey, height: 1.5),
          ),
        ],
      ),
    );
  }
}