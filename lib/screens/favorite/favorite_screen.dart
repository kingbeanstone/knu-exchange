import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../models/facility.dart';
import '../../widgets/facility_card.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // 샘플 데이터
  final List<Facility> _favoriteFacilities = [
    Facility(
      id: 'global_plaza',
      korName: '글로벌플라자 (국제교류처)',
      engName: 'Global Plaza (Office of International Affairs)',
      latitude: 35.8899,
      longitude: 128.6105,
      korDesc: '교환학생 관련 서류 제출 및 상담이 진행되는 곳입니다.',
      engDesc: 'Office for international exchange programs and documents.',
      category: 'Admin',
    ),
    Facility(
      id: 'gs25_dorm',
      korName: 'GS25 첨성관점',
      engName: 'GS25 Cheomseong-gwan',
      latitude: 35.8865,
      longitude: 128.6146,
      korDesc: '첨성관 기숙사 1층에 있는 편의점입니다.',
      engDesc: 'Convenience store located in Cheomseong-gwan dorm.',
      category: 'Store',
    ),
  ];

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
          // 1. 즐겨찾기한 시설/장소 탭
          _favoriteFacilities.isEmpty
              ? _buildEmptyState('No favorite places yet.\nAdd places from the map!')
              : ListView.builder(
            padding: const EdgeInsets.only(top: 12, bottom: 20),
            itemCount: _favoriteFacilities.length,
            itemBuilder: (context, index) {
              return FacilityCard(
                facility: _favoriteFacilities[index],
                onTap: () {
                  // 상세 정보 페이지로 이동하거나 지도로 이동하는 로직
                },
              );
            },
          ),

          // 2. 즐겨찾기한 커뮤니티 게시글 탭
          _buildEmptyState('No favorite posts yet.\nSave useful tips from the community!'),
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