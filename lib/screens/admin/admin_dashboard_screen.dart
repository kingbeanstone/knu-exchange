import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/report_provider.dart';
import '../../providers/community_provider.dart';
import '../../widgets/admin/admin_report_card.dart';
import '../../utils/app_colors.dart';
import '../../utils/facility_seeder.dart'; // [추가] 시더 임포트

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReportProvider>().fetchAllReports();
    });
  }

  Future<void> _handleDeleteContent(String targetId, String reportId) async {
    final reportProvider = context.read<ReportProvider>();
    final communityProvider = context.read<CommunityProvider>();

    try {
      await communityProvider.deletePost(targetId);
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
        actions: [
          // [추가] 상단바에 데이터 시딩 버튼 배치
          IconButton(
            icon: const Icon(Icons.add_location_alt_rounded),
            tooltip: 'Add Default Facilities',
            onPressed: () => FacilitySeeder.seedNewFacilities(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // [추가] 관리 도구 영역
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Data Management",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () => FacilitySeeder.seedNewFacilities(context),
                  icon: const Icon(Icons.library_add_rounded),
                  label: const Text("Seed Library & Gym Data"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.knuRed,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // 기존 신고 목록 영역
          Expanded(
            child: reportProvider.isLoading
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
          ),
        ],
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