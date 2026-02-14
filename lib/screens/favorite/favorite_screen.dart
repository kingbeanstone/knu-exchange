import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../models/facility.dart';
import '../../widgets/facility_card.dart';
import 'package:provider/provider.dart';
import '../../providers/favorite_provider.dart';
import '../../services/map_service.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // 탭 항목을 1개로 설정하여 'Places'만 나타나도록 합니다.
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
        // 탭바를 다시 추가하되, 탭 항목은 'Places' 하나만 넣습니다.
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
      // TabBarView를 사용하여 탭 구조를 유지합니다.
      body: TabBarView(
        controller: _tabController,
        children: [
          Consumer<FavoriteProvider>(
            builder: (context, favoriteProvider, child) {
              final favoriteIds = favoriteProvider.favoriteIds;

              // 전체 시설 중 즐겨찾기에 포함된 시설만 필터링
              final allFacilities = MapService().getAllFacilities();

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
                  return FacilityCard(
                    facility: favoriteFacilities[index],
                    onTap: () {
                      // 필요한 경우 상세 화면 이동 로직을 추가하세요.
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  // 데이터가 없을 때 표시할 화면
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