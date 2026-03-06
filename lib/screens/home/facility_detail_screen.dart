import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/facility.dart';
import '../../utils/app_colors.dart';
import '../../widgets/facility_photos_tab.dart';
import '../../widgets/facility_menu_tab.dart';

class FacilityDetailScreen extends StatefulWidget {
  final Facility facility;
  const FacilityDetailScreen({super.key, required this.facility});

  @override
  State<FacilityDetailScreen> createState() => _FacilityDetailScreenState();
}

class _FacilityDetailScreenState extends State<FacilityDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late bool _showMenuTab;

  @override
  void initState() {
    super.initState();
    _showMenuTab = widget.facility.category == 'Restaurant' || widget.facility.category == 'Cafe';
    // [수정] Floor 탭 제거에 따라 전체 길이를 1씩 줄임 (4->3 또는 3->2)
    _tabController = TabController(length: _showMenuTab ? 3 : 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('facilities').doc(widget.facility.id).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Scaffold(body: Center(child: CircularProgressIndicator()));

        final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};
        final List<String> customHeaders = List<String>.from(data['menuHeaders'] ?? []);

        final f = Facility(
          id: widget.facility.id,
          korName: data['korName'] ?? '',
          engName: data['engName'] ?? '',
          latitude: widget.facility.latitude,
          longitude: widget.facility.longitude,
          korDesc: data['korDesc'] ?? '',
          engDesc: data['engDesc'] ?? '',
          category: data['category'] ?? '',
          imageUrl: data['imageUrl'],
          operatingHours: data['operatingHours'],
          interiorImages: List<String>.from(data['interiorImages'] ?? []),
        );

        return Scaffold(
          body: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  expandedHeight: 200.0,
                  pinned: true,
                  backgroundColor: AppColors.knuRed,
                  foregroundColor: Colors.white,
                  flexibleSpace: LayoutBuilder(
                    builder: (BuildContext context, BoxConstraints constraints) {
                      var top = constraints.biggest.height;
                      double expandRatio = ((top - 104) / (200 - 104)).clamp(0.0, 1.0);
                      double paddingStart = 56.0 - (36.0 * expandRatio);

                      return FlexibleSpaceBar(
                        centerTitle: false,
                        titlePadding: EdgeInsetsDirectional.only(
                          start: paddingStart,
                          bottom: 62,
                        ),
                        title: Text(
                          f.engName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        background: Stack(
                          fit: StackFit.expand,
                          children: [
                            f.imageUrl != null
                                ? Image.network(f.imageUrl!, fit: BoxFit.cover)
                                : Container(color: Colors.grey[300]),
                            const DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [Colors.transparent, Colors.black54],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(48),
                    child: Container(
                      color: Colors.white,
                      child: TabBar(
                        controller: _tabController,
                        labelColor: AppColors.knuRed,
                        unselectedLabelColor: Colors.grey,
                        indicatorColor: AppColors.knuRed,
                        tabs: [
                          const Tab(text: 'Home'),
                          if (_showMenuTab) const Tab(text: 'Menu'),
                          const Tab(text: 'Photos'),
                          // [삭제] Floor 탭
                        ],
                      ),
                    ),
                  ),
                ),
              ];
            },
            body: TabBarView(
              controller: _tabController,
              children: [
                _buildHomeTab(f),
                if (_showMenuTab) FacilityMenuTab(facility: f, customHeaders: customHeaders),
                FacilityPhotosTab(photos: f.interiorImages ?? []),
                // [삭제] Floor 탭 컨텐츠
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHomeTab(Facility f) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow(Icons.category, "Category", f.category),
          _buildInfoRow(Icons.access_time, "Operating Hours", f.operatingHours ?? "Not specified"),
          const Divider(height: 40),
          const Text("Description", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text(f.engDesc, style: const TextStyle(fontSize: 16, height: 1.6)),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String content) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: AppColors.knuRed, size: 22),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 11, color: Colors.grey)),
              Text(content, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }
}