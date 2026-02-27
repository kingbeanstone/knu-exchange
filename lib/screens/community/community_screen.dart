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
import '../../widgets/community/community_search_bar.dart';
import '../../widgets/community/community_app_bar.dart';
import '../../widgets/community/community_empty_state.dart';
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

    // 서비스 초기화
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      if (auth.isAuthenticated) {
        // 1. 인앱 알림 서비스 초기화
        Provider.of<NotificationProvider>(context, listen: false)
            .initNotifications(auth.user!.uid);

        // 2. FCM 토큰 획득 및 서버 등록 프로세스 시작
        Provider.of<FCMProvider>(context, listen: false)
            .setupFCM(auth.user!.uid);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final provider = Provider.of<CommunityProvider>(context, listen: false);
    final auth = Provider.of<AuthProvider>(context, listen: false);

    if (!provider.isSearching &&
        _scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200) {
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
          : communityProvider.searchResults
          .where((p) => p.category == selectedCategory)
          .toList();
    } else {
      displayPosts = communityProvider.posts;
    }

    return Scaffold(
      // 공지사항과 동일한 연한 회색 배경
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: const CommunityAppBar(title: 'KNU Community'),
      body: Column(
        children: [
          // 상단바 장식선
          Container(height: 1, color: Colors.grey[200]),
          // 검색바
          CommunitySearchBar(
            onSearch: (query) => communityProvider.performSearch(query),
            onClear: () => communityProvider.clearSearch(),
          ),
          // [수정] 2줄 필터 위젯이 들어가는 영역
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
          // 리스트 시작 부분에 약간의 여백 추가
          const SizedBox(height: 4),
          Expanded(
            child: communityProvider.isLoading
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
              ),
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: displayPosts.length +
                    (!communityProvider.isSearching &&
                        communityProvider.hasMore
                        ? 1
                        : 0),
                itemBuilder: (context, index) {
                  if (index < displayPosts.length) {
                    return PostCard(post: displayPosts[index]);
                  } else {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: Center(child: CircularProgressIndicator(color: AppColors.knuRed)),
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
        elevation: 4,
        child: const Icon(Icons.edit, color: Colors.white),
      ),
    );
  }
}