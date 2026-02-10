import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../models/post.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  // 샘플 데이터 리스트
  final List<Post> _allPosts = [
    Post(
      id: '1',
      title: 'How to get a student ID card?',
      content: 'I just arrived and I don\'t know where to go for the ID card...',
      author: 'JohnDoe',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      category: PostCategory.question,
      likes: 5,
      comments: 3,
    ),
    Post(
      id: '2',
      title: 'Selling my bike (Cheap!)',
      content: 'Good condition, I\'m leaving Korea next month.',
      author: 'Emma_W',
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      category: PostCategory.market,
      likes: 12,
      comments: 1,
    ),
    Post(
      id: '3',
      title: 'Nice cafe near the North Gate',
      content: 'I found a very quiet place to study near the North Gate...',
      author: 'K-Student',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      category: PostCategory.tip,
      likes: 24,
      comments: 8,
    ),
  ];

  PostCategory? _selectedCategory; // null이면 전체보기

  @override
  Widget build(BuildContext context) {
    // 필터링된 게시글 리스트
    final filteredPosts = _selectedCategory == null
        ? _allPosts
        : _allPosts.where((p) => p.category == _selectedCategory).toList();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('KNU Community'),
        backgroundColor: AppColors.knuRed,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          IconButton(icon: const Icon(Icons.notifications_none), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          // 1. 카테고리 선택 탭
          _buildCategoryBar(),

          // 2. 게시글 리스트
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: filteredPosts.length,
              itemBuilder: (context, index) {
                return _buildPostCard(filteredPosts[index]);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 글쓰기 페이지 이동 로직
        },
        backgroundColor: AppColors.knuRed,
        child: const Icon(Icons.edit, color: Colors.white),
      ),
    );
  }

  // 상단 카테고리 필터 바
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
        onSelected: (selected) {
          setState(() {
            _selectedCategory = category;
          });
        },
        selectedColor: AppColors.knuRed,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        showCheckmark: false,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  // 게시글 카드 UI
  Widget _buildPostCard(Post post) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: () {
          // 게시글 상세 이동
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 카테고리 태그 및 작성 시간
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.knuRed.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      post.categoryLabel,
                      style: const TextStyle(
                        color: AppColors.knuRed,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    '2h ago', // 실제로는 post.createdAt 계산 로직 필요
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 제목
              Text(
                post.title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),

              // 내용 요약
              Text(
                post.content,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey[700], fontSize: 14),
              ),
              const SizedBox(height: 16),

              // 하단 정보 (작성자, 좋아요, 댓글)
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