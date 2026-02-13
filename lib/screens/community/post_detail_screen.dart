import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/post.dart';
import '../../providers/community_provider.dart';
import '../../providers/comment_provider.dart';
import '../../utils/app_colors.dart';
import '../../widgets/comment_section.dart';
import '../../widgets/post_action_bar.dart';

class PostDetailScreen extends StatefulWidget {
  final Post post;
  const PostDetailScreen({super.key, required this.post});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  late Post _currentPost;
  bool _isFetching = true;

  @override
  void initState() {
    super.initState();
    _currentPost = widget.post;
    _initData();
  }

  Future<void> _initData() async {
    final communityProvider = Provider.of<CommunityProvider>(context, listen: false);
    final commentProvider = Provider.of<CommentProvider>(context, listen: false);

    await Future.wait([
      communityProvider.getPostDetail(widget.post.id).then((p) {
        if (p != null && mounted) setState(() => _currentPost = p);
      }),
      commentProvider.loadComments(widget.post.id),
    ]);

    if (mounted) setState(() => _isFetching = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Post Detail'),
        backgroundColor: AppColors.knuRed,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      // 핵심: Column으로 묶어서 스크롤 영역과 입력창 영역을 완전히 분리
      body: _isFetching
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const Divider(height: 40),
                  SelectionArea(
                      child: Text(
                          _currentPost.content,
                          style: const TextStyle(fontSize: 16, height: 1.7)
                      )
                  ),
                  const SizedBox(height: 40),
                  // 댓글 목록 (입력창 제외)
                  CommentSection(postId: _currentPost.id),
                ],
              ),
            ),
          ),
          // 카톡 스타일: 키보드가 올라오면 이 입력창이 자동으로 밀려 올라감
          CommentInput(postId: _currentPost.id),
        ],
      ),
      bottomNavigationBar: PostActionBar(post: _currentPost),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
              color: AppColors.knuRed.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4)
          ),
          child: Text(
              _currentPost.categoryLabel.toUpperCase(),
              style: const TextStyle(color: AppColors.knuRed, fontSize: 11, fontWeight: FontWeight.bold)
          ),
        ),
        const SizedBox(height: 16),
        Text(
            _currentPost.title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, height: 1.3)
        ),
        const SizedBox(height: 20),
        Row(children: [
          const CircleAvatar(
              backgroundColor: AppColors.lightGrey,
              child: Icon(Icons.person, color: Colors.grey)
          ),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(_currentPost.author, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            Text(
                '${_currentPost.createdAt.year}.${_currentPost.createdAt.month}.${_currentPost.createdAt.day}',
                style: const TextStyle(color: Colors.grey, fontSize: 12)
            ),
          ]),
        ]),
      ],
    );
  }
}