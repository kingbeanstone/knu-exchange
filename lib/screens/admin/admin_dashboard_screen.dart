import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/report_provider.dart';
import '../../providers/feedback_provider.dart';
import '../../providers/community_provider.dart';
import '../../widgets/admin/admin_report_card.dart';
import '../../widgets/admin/admin_feedback_card.dart';
import '../../utils/app_colors.dart';
import '../../utils/facility_seeder.dart';

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
      _refreshAll();
    });
  }

  Future<void> _refreshAll() async {
    await Future.wait([
      context.read<ReportProvider>().fetchAllReports(),
      context.read<FeedbackProvider>().fetchAllFeedbacks(),
    ]);
  }

  Future<void> _handleDeleteContent(String targetId, String reportId) async {
    try {
      await context.read<CommunityProvider>().deletePost(targetId);
      await context.read<ReportProvider>().removeReportRecord(reportId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Content removed successfully.")),
        );
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          title: const Text("Admin Panel"),
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          centerTitle: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.add_location_alt_outlined),
              tooltip: 'Seed Map Data',
              onPressed: () => FacilitySeeder.seedNewFacilities(context),
            ),
          ],
          bottom: const TabBar(
            indicatorColor: AppColors.knuRed,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: "REPORTS", icon: Icon(Icons.report_gmailerrorred_rounded, size: 20)),
              Tab(text: "FEEDBACKS", icon: Icon(Icons.rate_review_outlined, size: 20)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildReportTab(),
            _buildFeedbackTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildReportTab() {
    final provider = context.watch<ReportProvider>();
    return RefreshIndicator(
      onRefresh: provider.fetchAllReports,
      child: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.reports.isEmpty
          ? _buildEmptyState("No pending reports.")
          : ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 12),
        itemCount: provider.reports.length,
        itemBuilder: (context, index) {
          final report = provider.reports[index];
          return AdminReportCard(
            report: report,
            onDeleteAction: () => _handleDeleteContent(report.targetId, report.id),
          );
        },
      ),
    );
  }

  Widget _buildFeedbackTab() {
    final provider = context.watch<FeedbackProvider>();
    return RefreshIndicator(
      onRefresh: provider.fetchAllFeedbacks,
      child: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.feedbacks.isEmpty
          ? _buildEmptyState("No feedback received.")
          : ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 12),
        itemCount: provider.feedbacks.length,
        itemBuilder: (context, index) {
          final feedback = provider.feedbacks[index];
          return AdminFeedbackCard(
            feedback: feedback,
            onDelete: () => provider.removeFeedback(feedback['id']),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(String msg) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_rounded, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(msg, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}