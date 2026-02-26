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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      await FirebaseFirestore.instance.collection('notices').add({
        'title': _titleController.text.trim(),
        'content': _contentController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notice posted successfully.')),
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
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: AppColors.knuRed, // 빨간색 배경 유지
        foregroundColor: Colors.white,    // 흰색 글자색 유지
        elevation: 0,
        centerTitle: false,               // 왼쪽 정렬 유지
        actions: [
          // 통일감을 위해 텍스트 버튼 대신 아이콘 버튼(체크표시) 사용
          IconButton(
            onPressed: _isSubmitting ? null : _submit,
            icon: const Icon(Icons.check),
            tooltip: 'Post',
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
                "Title",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.grey
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  hintText: "Enter notice title",
                  hintStyle: TextStyle(color: Colors.grey[300]),
                  border: InputBorder.none,
                ),
                validator: (v) => v!.isEmpty ? 'Please enter title' : null,
              ),
              const Divider(height: 32),
              const Text(
                "Content (Markdown supported)",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.grey
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _contentController,
                maxLines: null,
                minLines: 10,
                style: const TextStyle(fontSize: 16, height: 1.6),
                decoration: InputDecoration(
                  hintText: "Write your notice here...",
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