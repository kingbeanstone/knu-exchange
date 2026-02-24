import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/community_provider.dart';
import '../../providers/auth_provider.dart'; // [추가] 사용자 정보를 가져오기 위해 필요
import '../../models/post.dart';
import '../../utils/app_colors.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  PostCategory _selectedCategory = PostCategory.free;
  bool _isSubmitting = false;
  bool _isAnonymous = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    // [수정] 사용자 정보를 가져오기 위해 AuthProvider 참조
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final communityProvider = Provider.of<CommunityProvider>(context, listen: false);

    final currentUser = authProvider.user;
    // 닉네임이 없을 경우를 대비해 이메일이나 기본값 설정
    final String displayName = currentUser?.displayName ?? currentUser?.email?.split('@')[0] ?? 'User';

    try {
      await communityProvider.addPost(
        Post(
          id: '',
          title: _titleController.text.trim(),
          content: _contentController.text.trim(),
          // [수정] 익명이 아닐 경우 실제 사용자의 닉네임과 UID를 저장
          author: _isAnonymous ? 'Anonymous' : displayName,
          authorId: currentUser?.uid ?? '',
          authorName: _isAnonymous ? 'Anonymous' : displayName,
          createdAt: DateTime.now(),
          category: _selectedCategory,
          isAnonymous: _isAnonymous,
        ),
      );

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to post: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Post'),
        backgroundColor: AppColors.knuRed,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _isSubmitting ? null : _submit,
            icon: const Icon(Icons.check),
          ),
        ],
      ),
      body: _isSubmitting
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DropdownButtonFormField<PostCategory>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: PostCategory.values.map((cat) {
                    return DropdownMenuItem(
                      value: cat,
                      child: Text(cat.toString().split('.').last.toUpperCase()),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedCategory = val);
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    hintText: 'Enter title for exchange students',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v!.isEmpty ? 'Please enter title' : null,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _contentController,
                  decoration: const InputDecoration(
                    labelText: 'Content',
                    hintText: 'Share information or ask questions...',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(),
                  ),
                  maxLines: null,
                  minLines: 12,
                  textAlignVertical: TextAlignVertical.top,
                  validator: (v) => v!.isEmpty ? 'Please enter content' : null,
                ),
                const SizedBox(height: 12),

                CheckboxListTile(
                  title: const Text(
                    "Post Anonymously",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                  ),
                  value: _isAnonymous,
                  activeColor: AppColors.knuRed,
                  onChanged: (val) {
                    setState(() => _isAnonymous = val ?? false);
                  },
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                ),

                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }
}