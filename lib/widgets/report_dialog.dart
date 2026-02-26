import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/report_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_colors.dart';

class ReportDialog extends StatefulWidget {
  final String targetId;
  final String targetType;

  const ReportDialog({
    super.key,
    required this.targetId,
    required this.targetType,
  });

  @override
  State<ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends State<ReportDialog> {
  // [수정] 신고 사유를 영어로 변경
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
    final reportProvider = context.watch<ReportProvider>();
    final authProvider = context.read<AuthProvider>();

    return AlertDialog(
      title: const Text('Report'), // [수정] 타이틀 영문 서비스명
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: _reasons.map((reason) {
            return RadioListTile<String>(
              title: Text(reason, style: const TextStyle(fontSize: 14)),
              value: reason,
              groupValue: _selectedReason,
              onChanged: (value) => setState(() => _selectedReason = value),
              activeColor: AppColors.knuRed,
              contentPadding: EdgeInsets.zero,
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'), // [수정]
        ),
        ElevatedButton(
          onPressed: (_selectedReason == null || reportProvider.isSubmitting)
              ? null
              : () async {
            try {
              await reportProvider.reportContent(
                targetId: widget.targetId,
                targetType: widget.targetType,
                reporterId: authProvider.user?.uid ?? 'anonymous',
                reason: _selectedReason!,
              );
              if (context.mounted) {
                Navigator.pop(context);
                // [수정] 성공 메시지 영문으로 변경
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Report submitted. We will review it shortly.'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            } catch (e) {
              if (context.mounted) {
                // [수정] 실패 메시지 영문으로 변경
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to submit report: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.knuRed,
            foregroundColor: Colors.white,
          ),
          child: reportProvider.isSubmitting
              ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
          )
              : const Text('Submit'), // [수정]
        ),
      ],
    );
  }
}