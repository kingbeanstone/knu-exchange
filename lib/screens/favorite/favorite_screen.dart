import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/app_colors.dart';
import '../../models/facility.dart';
import '../../widgets/facility_card.dart'; // 경로 확인 필요 (widgets/home/ 하위인지)
import '../../providers/favorite_provider.dart';
import '../../services/map_service.dart';
import '../home/facility_detail_screen.dart'; // 상세 페이지 이동을 위해 추가

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final MapService _mapService = MapService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('My Favorites'),
        backgroundColor: AppColors.knuRed,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Places'),
          ],
        ),
      ),
      // StreamBuilder를 사용하여 파이어베이스의 전체 시설 데이터를 실시간으로 가져옵니다.
      body: StreamBuilder<List<Facility>>(
        stream: _mapService.getFacilitiesStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text('Error loading data'));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final allFacilities = snapshot.data!;

          return TabBarView(
            controller: _tabController,
            children: [
              Consumer<FavoriteProvider>(
                builder: (context, favoriteProvider, child) {
                  final favoriteIds = favoriteProvider.favoriteIds;

                  // 파이어베이스 데이터 중 사용자의 즐겨찾기 ID 리스트에 포함된 것만 필터링
                  final favoriteFacilities = allFacilities
                      .where((facility) => favoriteIds.contains(facility.id))
                      .toList();

                  if (favoriteFacilities.isEmpty) {
                    return _buildEmptyState(
                        'No favorite places yet.\nAdd places from the map!');
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.only(top: 12, bottom: 20),
                    itemCount: favoriteFacilities.length,
                    itemBuilder: (context, index) {
                      final facility = favoriteFacilities[index];
                      return FacilityCard(
                        facility: facility,
                        onTap: () {
                          // 상세 페이지 이동 로직 추가
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => FacilityDetailScreen(facility: facility),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.favorite_border, size: 60, color: Colors.grey[300]),
          ),
          const SizedBox(height: 20),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.grey,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}