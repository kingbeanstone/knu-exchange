import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/community_provider.dart';
import '../../providers/auth_provider.dart';
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

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  PostCategory _toCategory(String value) {
    switch (value) {
      case 'question':
        return PostCategory.question;
      case 'tip':
        return PostCategory.tip;
      case 'market':
        return PostCategory.market;
      case 'free':
      default:
        return PostCategory.free;
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    // Provider 접근
    final communityProvider = Provider.of<CommunityProvider>(context, listen: false);

    try {
      // 수정된 로직: 인자에서 'authorName'을 제거합니다.
      // 서비스(CommunityService)가 현재 로그인된 사용자의 닉네임을 직접 처리합니다.
      await communityProvider.addPost(
        Post(
          id: '', // Firestore에서 자동 생성되므로 빈값 OK
          title: _titleController.text.trim(),
          content: _contentController.text.trim(),

          // ✅ 필수: 화면 표시용(닉네임 또는 이메일)
          author: 'Anonymous',

          // ✅ 필수: 권한 확인용 UID (지금 모르겠으면 임시로 빈 문자열)
          authorId: '',

          // ✅ 필수: 닉네임 필드 (지금 모르겠으면 author랑 동일하게)
          authorName: 'Anonymous',

          createdAt: DateTime.now(),

          // ✅ 중요: enum이어야 함
          category: _selectedCategory, // _selectedCategory 타입이 PostCategory여야 함!
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
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<PostCategory>(
                value: _selectedCategory,
                decoration: const InputDecoration(labelText: 'Category'),
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
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'Enter title for exchange students',
                ),
                validator: (v) => v!.isEmpty ? 'Please enter title' : null,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: TextFormField(
                  controller: _contentController,
                  decoration: const InputDecoration(
                    labelText: 'Content',
                    hintText: 'Share information or ask questions...',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(),
                  ),
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  validator: (v) => v!.isEmpty ? 'Please enter content' : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}