import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/report_provider.dart';
import '../../providers/community_provider.dart';
import '../../widgets/admin/admin_report_card.dart';
import '../../utils/app_colors.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    // 화면 진입 시 신고 목록 새로고침
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReportProvider>().fetchAllReports();
    });
  }

  Future<void> _handleDeleteContent(String targetId, String reportId) async {
    final reportProvider = context.read<ReportProvider>();
    final communityProvider = context.read<CommunityProvider>();

    try {
      // 1. 게시글 삭제 실행 (관리자 권한)
      await communityProvider.deletePost(targetId);
      // 2. 해당 신고 내역 종결 (삭제)
      await reportProvider.removeReportRecord(reportId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Content removed and report closed.")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to process: $e")),
        );
      }
    }
  }

  void _showConfirmDialog(String targetId, String reportId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Content?"),
        content: const Text("This will permanently delete the post and close the report."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _handleDeleteContent(targetId, reportId);
            },
            child: const Text("Delete", style: TextStyle(color: AppColors.knuRed)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reportProvider = context.watch<ReportProvider>();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: reportProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : reportProvider.reports.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
        onRefresh: reportProvider.fetchAllReports,
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 12),
          itemCount: reportProvider.reports.length,
          itemBuilder: (context, index) {
            final report = reportProvider.reports[index];
            return AdminReportCard(
              report: report,
              onDeleteAction: () => _showConfirmDialog(report.targetId, report.id),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_turned_in_outlined, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text("No pending reports.", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}