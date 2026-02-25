import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../providers/community_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/post.dart';
import '../../utils/app_colors.dart';
import '../../widgets/community/post_image_picker.dart';
import '../../widgets/community/post_form_fields.dart'; // [추가] 분리된 폼 필드 위젯

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  PostCategory _selectedCategory = PostCategory.free;
  bool _isSubmitting = false;
  bool _isAnonymous = false;
  List<File> _selectedImages = [];

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
          CircularProgressIndicator(),
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
            // 분리된 입력 폼 필드 위젯
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
            // 이미지 피커 위젯 [수정됨]
            PostImagePicker(
              existingUrls: const [], // 새 게시글이므로 기존 URL은 빈 리스트
              selectedImages: _selectedImages,
              onPickImages: _pickImages,
              onRemoveExisting: (index) {}, // 제거할 기존 이미지가 없음
              onRemoveNew: (index) => setState(() => _selectedImages.removeAt(index)),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}