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
  final List<String> _reasons = [
    '부적절한 콘텐츠 (Inappropriate content)',
    '스팸 또는 홍보성 (Spam or promotion)',
    '혐오 표현 또는 괴롭힘 (Hate speech or harassment)',
    '잘못된 정보 (Misinformation)',
    '기타 (Other)',
  ];
  String? _selectedReason;

  @override
  Widget build(BuildContext context) {
    final reportProvider = context.watch<ReportProvider>();
    final authProvider = context.read<AuthProvider>();

    return AlertDialog(
      title: const Text('신고하기 (Report)'),
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
          child: const Text('취소 (Cancel)'),
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
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('신고가 접수되었습니다. 검토 후 조치하겠습니다.')),
                );
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('신고 제출 실패: $e')),
                );
              }
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.knuRed,
            foregroundColor: Colors.white,
          ),
          child: reportProvider.isSubmitting
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text('제출 (Submit)'),
        ),
      ],
    );
  }
}