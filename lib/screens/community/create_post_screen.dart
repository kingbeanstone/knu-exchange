import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/community_provider.dart';
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

    final communityProvider = Provider.of<CommunityProvider>(context, listen: false);

    try {
      await communityProvider.addPost(
        Post(
          id: '',
          title: _titleController.text.trim(),
          content: _contentController.text.trim(),
          author: _isAnonymous ? 'Anonymous' : 'User',
          authorId: '',
          authorName: _isAnonymous ? 'Anonymous' : 'Real Name',
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

                // 익명 게시 체크박스 오타 수정 완료
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
                  // controlType -> controlAffinity로 수정
                  // ListTileControlType -> ListTileControlAffinity로 수정
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