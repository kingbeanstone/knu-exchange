import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../providers/community_provider.dart';
import '../../models/post.dart';
import '../../utils/app_colors.dart';
import '../../widgets/community/post_image_picker.dart';

class EditPostScreen extends StatefulWidget {
  final Post post;
  const EditPostScreen({super.key, required this.post});

  @override
  State<EditPostScreen> createState() => _EditPostScreenState();
}

class _EditPostScreenState extends State<EditPostScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late PostCategory _selectedCategory;
  late bool _isAnonymous;

  final ImagePicker _picker = ImagePicker();
  List<File> _newImages = [];
  late List<String> _existingUrls;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.post.title);
    _contentController = TextEditingController(text: widget.post.content);
    _selectedCategory = widget.post.category;
    _isAnonymous = widget.post.isAnonymous;
    _existingUrls = List.from(widget.post.imageUrls);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final int totalCount = _existingUrls.length + _newImages.length;
    if (totalCount >= 10) return;

    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        final remaining = 10 - totalCount;
        _newImages.addAll(
          images.take(remaining).map((xfile) => File(xfile.path)).toList(),
        );
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final provider = Provider.of<CommunityProvider>(context, listen: false);

      final editedPost = Post(
        id: widget.post.id,
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        author: widget.post.author,
        authorId: widget.post.authorId,
        authorName: widget.post.authorName,
        createdAt: widget.post.createdAt,
        category: _selectedCategory,
        isAnonymous: _isAnonymous,
        likes: widget.post.likes,
        comments: widget.post.comments,
        imageUrls: const [],
      );

      // [수정] updatePost 호출 시 onRefresh 파라미터를 필수값으로 전달합니다.
      await provider.updatePost(
        editedPost,
        newImages: _newImages,
        remainingUrls: _existingUrls,
        onRefresh: () => provider.fetchPosts(isRefresh: true),
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Post updated successfully.")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to update post: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Edit Post'),
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
                  ),
                  items: PostCategory.values.where((c) => c != PostCategory.hot).map((cat) {
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
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v!.isEmpty ? 'Please enter title' : null,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _contentController,
                  decoration: const InputDecoration(
                    labelText: 'Content',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: null,
                  minLines: 10,
                  validator: (v) => v!.isEmpty ? 'Please enter content' : null,
                ),
                const SizedBox(height: 24),
                PostImagePicker(
                  existingUrls: _existingUrls,
                  selectedImages: _newImages,
                  onPickImages: _pickImages,
                  onRemoveExisting: (idx) => setState(() => _existingUrls.removeAt(idx)),
                  onRemoveNew: (idx) => setState(() => _newImages.removeAt(idx)),
                ),
                const SizedBox(height: 20),
                CheckboxListTile(
                  title: const Text("Post Anonymously"),
                  value: _isAnonymous,
                  activeColor: AppColors.knuRed,
                  onChanged: (val) => setState(() => _isAnonymous = val ?? false),
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}