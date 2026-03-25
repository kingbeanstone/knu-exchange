import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

class ResendVerificationDialog extends StatelessWidget {
  final VoidCallback onResend;

  const ResendVerificationDialog({super.key, required this.onResend});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Row(
        children: [
          Icon(Icons.mark_email_unread_outlined, color: AppColors.knuRed),
          SizedBox(width: 8),
          Text('Verify Email', style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your email has not been verified yet.'),
          SizedBox(height: 12),
          Text(
            'The link might have expired or gone to your spam folder. Would you like us to send a new link?',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: () {
            onResend();
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.knuRed,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text('Resend Link'),
        ),
      ],
    );
  }
}