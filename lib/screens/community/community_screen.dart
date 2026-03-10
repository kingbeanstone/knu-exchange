import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/app_colors.dart';
import '../../models/post.dart';
import '../../providers/community_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/fcm_provider.dart';
import '../../widgets/community/post_card.dart';
import '../../widgets/community/community_category_filter.dart';
import '../../widgets/community/community_app_bar.dart';
import '../../widgets/community/community_empty_state.dart';
import '../../widgets/common/login_prompt_modal.dart';
import 'create_post_screen.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchMode = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    // [핵심 수정] 화면이 렌더링된 직후 초기 데이터를 불러옵니다.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();

      final auth = Provider.of<AuthProvider>(context, listen: false);
      if (auth.isAuthenticated) {
        Provider.of<NotificationProvider>(context, listen: false)
            .initNotifications(auth.user!.uid);
        Provider.of<FCMProvider>(context, listen: false)
            .setupFCM(auth.user!.uid);
      }
    });
  }

  // [추가] 유저 정보를 포함하여 첫 게시글을 불러오는 함수
  void _loadInitialData() {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final community = Provider.of<CommunityProvider>(context, listen: false);

    // 유저의 차단 목록을 포함하여 게시글을 가져옵니다.
    community.fetchPosts(
      isRefresh: true,
      userId: auth.user?.uid,
      blockedUsers: auth.userModel?.blockedUsers,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final provider = Provider.of<CommunityProvider>(context, listen: false);
    final auth = Provider.of<AuthProvider>(context, listen: false);

    if (!provider.isSearching &&
        _scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 100) { // 200에서 100으로 조정하여 더 끝에서 호출
      if (provider.hasMore && !provider.isLoadingMore && !provider.isLoading) {
        provider.fetchPosts(
          userId: auth.user?.uid,
          blockedUsers: auth.userModel?.blockedUsers,
        );
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
          : communityProvider.searchResults
          .where((p) => p.category == selectedCategory)
          .toList();
    } else {
      displayPosts = communityProvider.posts;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: CommunityAppBar(
        title: 'Community',
        isSearchMode: _isSearchMode,
        searchController: _searchController,
        onSearchToggle: () {
          setState(() {
            _isSearchMode = !_isSearchMode;
            if (!_isSearchMode) {
              _searchController.clear();
              communityProvider.clearSearch();
            }
          });
        },
        // [수정] 검색 시 차단 목록 전달
        onSearchChanged: (val) => communityProvider.performSearch(
          val,
          blockedUsers: auth.userModel?.blockedUsers,
        ),
      ),
      body: Column(
        children: [
          if (!_isSearchMode)
            Container(height: 1, color: Colors.grey[200]),

          CommunityCategoryFilter(
            selectedCategory: selectedCategory,
            isMyPostsSelected: isMyPostsOnly,
            onCategorySelected: (category) {
              // [수정] 카테고리 변경 시 차단 목록 전달
              communityProvider.setCategory(category, blockedUsers: auth.userModel?.blockedUsers);
            },
            onMyPostsSelected: (isActive) {
              if (!auth.isAuthenticated) {
                LoginPromptModal.show(context, message: 'Login is required to see your posts.');
                return;
              }
              // [수정] 내 글 보기 시 차단 목록 전달
              communityProvider.setMyPostsOnly(isActive, auth.user?.uid, blockedUsers: auth.userModel?.blockedUsers);
            },
          ),
          const SizedBox(height: 4),
          Expanded(
            child: communityProvider.isLoading && communityProvider.posts.isEmpty
                ? const Center(child: CircularProgressIndicator(color: AppColors.knuRed))
                : displayPosts.isEmpty
                ? CommunityEmptyState(
              isSearching: communityProvider.isSearching,
              isMyPostsOnly: isMyPostsOnly,
            )
                : RefreshIndicator(
              color: AppColors.knuRed,
              onRefresh: () => communityProvider.fetchPosts(
                isRefresh: true,
                userId: auth.user?.uid,
                blockedUsers: auth.userModel?.blockedUsers,
              ),
              child: ListView.builder(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(), // 데이터가 적어도 새로고침 가능하게
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                // [핵심 수정] 하단 스피너는 로딩 중일 때만 항목 추가
                itemCount: displayPosts.length + (communityProvider.isLoadingMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index < displayPosts.length) {
                    return PostCard(post: displayPosts[index]);
                  } else {
                    // isLoadingMore가 true일 때만 이 빌더가 호출됨
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: AppColors.knuRed,
                            strokeWidth: 2,
                          ),
                        ),
                      ),
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
          if (!auth.isAuthenticated) {
            LoginPromptModal.show(context, message: 'Please log in to share your thoughts with the community.');
            return;
          }

          PostCategory initialCategory = PostCategory.lounge;
          if (selectedCategory != null &&
              selectedCategory != PostCategory.hot &&
              !isMyPostsOnly) {
            initialCategory = selectedCategory;
          }
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreatePostScreen(initialCategory: initialCategory),
            ),
          );
        },
        backgroundColor: AppColors.knuRed,
        elevation: 4,
        child: const Icon(Icons.edit, color: Colors.white),
      ),
    );
  }
}