import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../utils/app_colors.dart';
import '../../services/notice_service.dart';
import '../../services/storage_service.dart';
import '../../widgets/notice/create_notice_widgets.dart';

class CreateNoticeScreen extends StatefulWidget {
  const CreateNoticeScreen({super.key});

  @override
  State<CreateNoticeScreen> createState() => _CreateNoticeScreenState();
}

class _CreateNoticeScreenState extends State<CreateNoticeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  final NoticeService _noticeService = NoticeService();
  final StorageService _storageService = StorageService();
  final ImagePicker _picker = ImagePicker();

  List<File> _selectedImages = [];
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  /// 여러 장의 이미지 선택 로직
  Future<void> _handlePickImages() async {
    if (_selectedImages.length >= 10) return;

    final List<XFile> pickedFiles = await _picker.pickMultiImage(
      imageQuality: 80,
    );

    if (pickedFiles.isNotEmpty) {
      setState(() {
        final remainingSpace = 10 - _selectedImages.length;
        _selectedImages.addAll(
            pickedFiles.take(remainingSpace).map((xfile) => File(xfile.path)).toList()
        );
      });
    }
  }

  /// 공지사항 업로드 로직
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      List<String> imageUrls = [];

      // 1. 선택된 모든 이미지를 스토리지에 병렬 업로드
      if (_selectedImages.isNotEmpty) {
        imageUrls = await _storageService.uploadMultipleImages(
          imageFiles: _selectedImages,
          storagePath: 'notices',
        );
      }

      // 2. Firestore에 공지 데이터 저장 (imageUrls 리스트 전달)
      await _noticeService.addNotice(
        _titleController.text.trim(),
        _contentController.text.trim(),
        imageUrls: imageUrls,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notice posted with images!'),
            backgroundColor: Colors.green,
          ),
        );
      }
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'New Notice',
          style: TextStyle(fontWeight: FontWeight.normal, fontSize: 18),
        ),
        backgroundColor: AppColors.knuRed,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _isSubmitting ? null : _submit,
            icon: const Icon(Icons.check),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isSubmitting
          ? const Center(child: CircularProgressIndicator(color: AppColors.knuRed))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CreateNoticeInputLabel(text: "NOTICE TITLE"),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                decoration: const InputDecoration(
                  hintText: "Enter title for all students",
                  border: InputBorder.none,
                ),
                validator: (v) => v!.isEmpty ? 'Please enter title' : null,
              ),
              const Divider(height: 32),

              const CreateNoticeInputLabel(text: "ATTACHMENTS"),
              const SizedBox(height: 12),
              // 위젯의 파라미터 이름을 정의와 일치시킴
              CreateNoticeImagePicker(
                selectedImages: _selectedImages,
                onPickImages: _handlePickImages,
                onRemoveImage: (index) => setState(() => _selectedImages.removeAt(index)),
              ),
              const Divider(height: 48),

              const CreateNoticeInputLabel(text: "CONTENT"),
              const SizedBox(height: 8),
              TextFormField(
                controller: _contentController,
                maxLines: null,
                minLines: 10,
                style: const TextStyle(fontSize: 16, height: 1.6),
                decoration: const InputDecoration(
                  hintText: "Describe the announcement details...",
                  border: InputBorder.none,
                ),
                validator: (v) => v!.isEmpty ? 'Please enter content' : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}