import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../providers/community_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/post.dart';
import '../../utils/app_colors.dart';
import '../../widgets/community/post_image_picker.dart';
import '../../widgets/community/post_form_fields.dart';

class CreatePostScreen extends StatefulWidget {
  // [수정] 초기 카테고리를 받을 수 있는 생성자 추가
  final PostCategory? initialCategory;

  const CreatePostScreen({
    super.key,
    this.initialCategory,
  });

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  late PostCategory _selectedCategory; // late 선언으로 initState에서 초기화
  bool _isSubmitting = false;
  bool _isAnonymous = false;
  List<File> _selectedImages = [];

  @override
  void initState() {
    super.initState();
    // [수정] 전달받은 초기 카테고리가 있으면 사용, 없으면 Lounge 기본값
    _selectedCategory = widget.initialCategory ?? PostCategory.lounge;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    if (_selectedImages.length >= 10) {
      _showSnackBar('You can upload up to 10 images.');
      return;
    }

    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        final remaining = 10 - _selectedImages.length;
        _selectedImages.addAll(
            images.take(remaining).map((xfile) => File(xfile.path)).toList()
        );
      });
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final authProvider = context.read<AuthProvider>();
    final communityProvider = context.read<CommunityProvider>();
    final currentUser = authProvider.user;
    final String displayName = currentUser?.displayName ?? currentUser?.email?.split('@')[0] ?? 'User';

    try {
      await communityProvider.addPost(
        Post(
          id: '',
          title: _titleController.text.trim(),
          content: _contentController.text.trim(),
          author: _isAnonymous ? 'Anonymous' : displayName,
          authorId: currentUser?.uid ?? '',
          authorName: _isAnonymous ? 'Anonymous' : displayName,
          createdAt: DateTime.now(),
          category: _selectedCategory,
          isAnonymous: _isAnonymous,
        ),
        images: _selectedImages,
        onRefresh: () => communityProvider.fetchPosts(isRefresh: true),
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      _showSnackBar('Failed to post: $e');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
          ? _buildLoadingIndicator()
          : _buildBody(),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.knuRed),
          SizedBox(height: 16),
          Text('Uploading post...', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            PostFormFields(
              formKey: _formKey,
              selectedCategory: _selectedCategory,
              titleController: _titleController,
              contentController: _contentController,
              isAnonymous: _isAnonymous,
              onCategoryChanged: (val) {
                if (val != null) setState(() => _selectedCategory = val);
              },
              onAnonymousChanged: (val) => setState(() => _isAnonymous = val),
            ),
            const SizedBox(height: 20),
            PostImagePicker(
              existingUrls: const [],
              selectedImages: _selectedImages,
              onPickImages: _pickImages,
              onRemoveExisting: (index) {},
              onRemoveNew: (index) => setState(() => _selectedImages.removeAt(index)),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}