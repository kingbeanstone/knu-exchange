import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/feedback_service.dart';
import '../../utils/app_colors.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final TextEditingController _controller = TextEditingController();
  final FeedbackService _service = FeedbackService();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final String content = _controller.text.trim();
    if (content.isEmpty) return;

    setState(() => _isSubmitting = true);

    try {
      final auth = context.read<AuthProvider>();

      await _service.submitFeedback(
        content: content,
        userId: auth.user?.uid ?? 'anonymous',
        userEmail: auth.user?.email ?? 'anonymous',
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Feedback submitted successfully. Thank you!'),
            backgroundColor: Colors.black87,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit: $e')),
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
          'Send Feedback',
          style: TextStyle(fontWeight: FontWeight.normal, fontSize: 18),
        ),
        backgroundColor: AppColors.knuRed,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: _isSubmitting ? null : _submit,
            icon: const Icon(Icons.send_rounded),
            tooltip: 'Submit',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Help us improve KNU Exchange",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkGrey
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "Share your suggestions, report bugs, or give us any feedback about your experience. We review every piece of feedback!",
                style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    height: 1.5
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: TextField(
                  controller: _controller,
                  maxLines: null,
                  minLines: 10,
                  autofocus: true,
                  style: const TextStyle(fontSize: 16, height: 1.6),
                  decoration: InputDecoration(
                    hintText: "Tell us what's on your mind...",
                    hintStyle: TextStyle(color: Colors.grey[300]),
                    filled: true,
                    fillColor: Colors.grey[50],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.all(20),
                  ),
                ),
              ),
              if (_isSubmitting)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(child: CircularProgressIndicator(color: AppColors.knuRed)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}