import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../utils/app_colors.dart';
import '../../services/notice_service.dart';
import '../../services/storage_service.dart';
import '../../widgets/notice/edit_notice_widgets.dart';

class EditNoticeScreen extends StatefulWidget {
  final String noticeId;
  final String initialTitle;
  final String initialContent;
  final List<String> initialImageUrls;

  const EditNoticeScreen({
    super.key,
    required this.noticeId,
    required this.initialTitle,
    required this.initialContent,
    required this.initialImageUrls,
  });

  @override
  State<EditNoticeScreen> createState() => _EditNoticeScreenState();
}

class _EditNoticeScreenState extends State<EditNoticeScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;

  final NoticeService _noticeService = NoticeService();
  final StorageService _storageService = StorageService();
  final ImagePicker _picker = ImagePicker();

  List<String> _keptUrls = [];
  List<File> _newFiles = [];
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle);
    _contentController = TextEditingController(text: widget.initialContent);
    _keptUrls = List.from(widget.initialImageUrls);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  /// 추가 이미지 선택
  Future<void> _handlePickImages() async {
    final int currentTotal = _keptUrls.length + _newFiles.length;
    if (currentTotal >= 10) return;

    final List<XFile> picked = await _picker.pickMultiImage(imageQuality: 70);
    if (picked.isNotEmpty) {
      setState(() {
        final space = 10 - currentTotal;
        _newFiles.addAll(picked.take(space).map((f) => File(f.path)));
      });
    }
  }

  /// 수정 사항 저장
  Future<void> _handleSave() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    if (title.isEmpty || content.isEmpty) return;

    setState(() => _isSaving = true);

    try {
      // 1. 새로 추가된 사진들 업로드
      List<String> newlyUploadedUrls = [];
      if (_newFiles.isNotEmpty) {
        newlyUploadedUrls = await _storageService.uploadMultipleImages(
          imageFiles: _newFiles,
          storagePath: 'notices',
        );
      }

      // 2. 최종 URL 리스트 구성 (유지된 것 + 새로 올라온 것)
      final List<String> finalUrls = [..._keptUrls, ...newlyUploadedUrls];

      // 3. Firestore 업데이트 호출
      await _noticeService.updateNotice(
        widget.noticeId,
        title,
        content,
        imageUrls: finalUrls,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Notice updated successfully.")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Update error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Edit Notice', style: TextStyle(fontSize: 18)),
        backgroundColor: AppColors.knuRed,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _isSaving ? null : _handleSave,
            icon: const Icon(Icons.check),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isSaving
          ? const Center(child: CircularProgressIndicator(color: AppColors.knuRed))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const EditNoticeInputLabel(text: "TITLE"),
            TextField(
              controller: _titleController,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(hintText: "Title", border: InputBorder.none),
            ),
            const Divider(height: 32),

            const EditNoticeInputLabel(text: "ATTACHMENTS"),
            const SizedBox(height: 12),
            EditNoticeImageEditor(
              existingUrls: _keptUrls,
              newFiles: _newFiles,
              onPickImages: _handlePickImages,
              onRemoveExisting: (i) => setState(() => _keptUrls.removeAt(i)),
              onRemoveNew: (i) => setState(() => _newFiles.removeAt(i)),
            ),
            const Divider(height: 32),

            const EditNoticeInputLabel(text: "CONTENT"),
            const SizedBox(height: 8),
            TextField(
              controller: _contentController,
              maxLines: null,
              minLines: 10,
              style: const TextStyle(fontSize: 16, height: 1.6),
              decoration: const InputDecoration(hintText: "Content", border: InputBorder.none),
            ),
          ],
        ),
      ),
    );
  }
}