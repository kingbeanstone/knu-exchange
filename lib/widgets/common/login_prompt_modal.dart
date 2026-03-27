import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../screens/auth/login_screen.dart';

class LoginPromptModal extends StatelessWidget {
  final String message;

  const LoginPromptModal({
    super.key,
    this.message = 'Please log in to use this feature.',
  });

  /// 이 모달을 띄우는 정적 메서드
  static Future<void> show(BuildContext context, {String? message}) {
    // [수정] 오타 수정: showModalBottomSheSet -> showModalBottomSheet
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => LoginPromptModal(message: message ?? 'Please log in to use this feature.'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Icon(Icons.lock_outline_rounded, size: 48, color: AppColors.knuRed),
          const SizedBox(height: 16),
          const Text(
            'Login Required',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.knuRed,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Go to Login', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Maybe Later', style: TextStyle(color: Colors.grey)),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}