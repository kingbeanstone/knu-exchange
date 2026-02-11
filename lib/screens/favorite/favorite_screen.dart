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
    _tabController = TabController(length: 2, vsync: this);
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
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'Places'),
            Tab(text: 'Community'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          Consumer<FavoriteProvider>(
            builder: (context, favoriteProvider, child) {
              final favoriteIds = favoriteProvider.favoriteIds;

              final allFacilities =
                  MapService().getFacilitiesByCategory('All');

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
                    onTap: () {},
                  );
                },
              );
            },
          ),
          _buildEmptyState(
              'No favorite posts yet.\nSave useful tips from the community!'),
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
              shape: BoxShape.circle, // BoxType.circle을 BoxShape.circle로 수정했습니다.
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