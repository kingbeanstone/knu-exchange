import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/report_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_colors.dart';

class ReportDialog extends StatefulWidget {
  final String targetId;
  final String targetType;
  final String reportedUserId; // 피신고자의 ID 필드 추가

  const ReportDialog({
    super.key,
    required this.targetId,
    required this.targetType,
    required this.reportedUserId, // 생성자에 필수 파라미터로 추가
  });

  @override
  State<ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends State<ReportDialog> {
  final List<String> _reasons = [
    'Inappropriate content',
    'Spam or promotion',
    'Hate speech or harassment',
    'Misinformation',
    'Other',
  ];
  String? _selectedReason;

  @override
  Widget build(BuildContext context) {
    // ReportProvider가 있다고 가정하고 구현합니다.
    final reportProvider = Provider.of<ReportProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text(
        'Report Content',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Why are you reporting this?',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 16),
            ..._reasons.map((reason) => RadioListTile<String>(
              title: Text(reason, style: const TextStyle(fontSize: 14)),
              value: reason,
              groupValue: _selectedReason,
              activeColor: AppColors.knuRed,
              contentPadding: EdgeInsets.zero,
              onChanged: (value) {
                setState(() {
                  _selectedReason = value;
                });
              },
            )),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: (_selectedReason == null || reportProvider.isSubmitting)
              ? null
              : () async {
            try {
              // Provider의 reportContent 메서드를 호출할 때 reportedUserId를 전달합니다.
              await reportProvider.reportContent(
                targetId: widget.targetId,
                targetType: widget.targetType,
                reportedUserId: widget.reportedUserId,
                reason: _selectedReason!,
                reporterId: authProvider.user?.uid ?? 'anonymous',
              );

              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Thank you for the report. We will review it.'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to submit report: $e')),
                );
              }
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.knuRed,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: reportProvider.isSubmitting
              ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
          )
              : const Text('Submit'),
        ),
      ],
    );
  }
}