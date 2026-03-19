import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/post.dart';
import '../../utils/app_colors.dart';
import '../../utils/date_formatter.dart';
import '../../screens/community/post_detail_screen.dart';
import '../../providers/community_provider.dart';
import '../../providers/auth_provider.dart';
import 'package:cached_network_image/cached_network_image.dart'; // ✅ 임포트 추가

class PostCard extends StatelessWidget {
  static final Set<String> _hiddenPosts = {};
  final Post post;

  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    if (_hiddenPosts.contains(post.id)) {
      return const SizedBox();
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            // [수정] withOpacity 대신 withValues 사용 (Line 26 경고 해결)
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // 상세 페이지에서 쓸 원본을 한 번 더 캐싱 시도
            precacheImage(CachedNetworkImageProvider(post.imageUrls.first), context);

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PostDetailScreen(post: post),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.knuRed.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        post.categoryLabel.toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.knuRed,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      DateFormatter.formatRelativeTime(post.createdAt),
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const Spacer(),
                    Transform.translate(
                      offset: const Offset(4, 0),
                      child: PopupMenuButton<String>(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(Icons.more_vert, size: 18, color: Colors.grey),
                        onSelected: (value) {
                          if (value == 'hide') {
                            // 숨기기 로직
                            final community = Provider.of<CommunityProvider>(context, listen: false);
                            community.removePostsByAuthor(post.authorId);
                            _hiddenPosts.add(post.id);
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Post hidden')));
                          }
                          // ✅ [추가] 차단 메뉴 선택 시 함수 호출
                          else if (value == 'block') {
                            _showBlockDialog(context, post.authorId, post.author);
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'hide',
                            child: Text('Hide Post'),
                          ),
                          // ✅ [추가] 차단 메뉴 아이템 추가
                          const PopupMenuItem(
                            value: 'block',
                            child: Text('Block User', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. 왼쪽: 텍스트 정보 (제목, 본문)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            post.title,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkGrey,
                              height: 1.3,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            post.content,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 2. 오른쪽: 이미지 (이미지가 있을 때만 표시)
                    if (post.imageUrls.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(left: 12),
                        child: Hero(
                          tag: post.imageUrls.first, // 상세 페이지와 연결되는 애니메이션 태그
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: CachedNetworkImage(
                              imageUrl: post.imageUrls.first,
                              width: 70,
                              height: 70,
                              fit: BoxFit.cover,
                              memCacheWidth: 200, // 리스트용 저해상도 캐싱 (메모리 절약)
                              placeholder: (context, url) => Container(
                                width: 70,
                                height: 70,
                                color: Colors.grey[100],
                              ),
                              errorWidget: (context, url, error) => Container(
                                width: 70,
                                height: 70,
                                color: Colors.grey[100],
                                child: const Icon(Icons.image_not_supported, color: Colors.grey, size: 20),
                              ),
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
                    _buildStatItem(Icons.favorite_border, post.likes.toString()),
                    const SizedBox(width: 12),
                    _buildStatItem(Icons.chat_bubble_outline, post.comments.toString()),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showBlockDialog(BuildContext context, String authorId, String authorName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Block User'),
        content: Text('Do you want to block "$authorName"? \nAll content from this user will be hidden instantly.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              final auth = Provider.of<AuthProvider>(context, listen: false);
              final community = Provider.of<CommunityProvider>(context, listen: false);

              if (auth.user == null) return;

              // [핵심 수정 1] 팝업창을 즉시 닫습니다.
              // await 앞에 두어야 사용자가 버튼을 누르자마자 창이 사라집니다.
              Navigator.pop(ctx);

              // 1. 차단 실행 (Mixin 로직 호출)
              // 이제 Mixin에서 finally로 로딩을 해제하므로 빙글빙글이 멈출 것입니다.
              await community.blockUser(
                currentUserId: auth.user!.uid,
                blockedUserId: authorId,
                blockedUserName: authorName,
                onBlockedUI: () {
                  // 2. 즉시 UI에서 제거 (애플 필수 조건)
                  community.removePostsByAuthor(authorId);
                },
              );

              // 3. [동기화] 내 로컬 모델의 차단 목록 업데이트
              await auth.refreshUserModel();

              // [핵심 수정 2] SnackBar 표시 시 현재 화면이 살아있는지 확인
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('User blocked successfully.'))
                );
              }
            },
            child: const Text('Block', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String count) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey[400]),
        const SizedBox(width: 4),
        Text(
          count,
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ],
    );
  }
}