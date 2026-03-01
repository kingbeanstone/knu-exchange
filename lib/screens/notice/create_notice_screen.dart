import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/app_colors.dart';

class CreateNoticeScreen extends StatefulWidget {
  const CreateNoticeScreen({super.key});

  @override
  State<CreateNoticeScreen> createState() => _CreateNoticeScreenState();
}

class _CreateNoticeScreenState extends State<CreateNoticeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  bool _isSubmitting = false;

  /// 공지사항 업로드 및 푸시 알림 트리거
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      // [중요] Cloud Functions(index.js)의 onNoticeCreated 트리거 경로인
      // 'notices' 컬렉션에 문서를 추가합니다.
      await FirebaseFirestore.instance.collection('notices').add({
        'title': _titleController.text.trim(),
        'content': _contentController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notice posted! Push notifications are being sent.'),
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
        centerTitle: true, // 제목 중앙 정렬 통일
        actions: [
          IconButton(
            onPressed: _isSubmitting ? null : _submit,
            icon: const Icon(Icons.check),
            tooltip: 'Post Notice',
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
              const Text(
                "NOTICE TITLE",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey, letterSpacing: 1.0),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  hintText: "Enter title for all students",
                  hintStyle: TextStyle(color: Colors.grey[300]),
                  border: InputBorder.none,
                ),
                validator: (v) => v!.isEmpty ? 'Please enter title' : null,
              ),
              const Divider(height: 32),
              const Text(
                "CONTENT",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey, letterSpacing: 1.0),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _contentController,
                maxLines: null,
                minLines: 12,
                style: const TextStyle(fontSize: 16, height: 1.6),
                decoration: InputDecoration(
                  hintText: "Describe the announcement details...",
                  hintStyle: TextStyle(color: Colors.grey[300]),
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