import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import '../../utils/app_colors.dart';
import '../../models/facility.dart';
import '../../services/map_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late NaverMapController _mapController;
  final MapService _mapService = MapService();

  // 현재 선택된 카테고리 (All, Cafe, Store, Restaurant, Admin)
  String _selectedCategory = 'All';

  // 카테고리 버튼 데이터
  final List<Map<String, dynamic>> _categories = [
    {'label': 'All', 'icon': Icons.map, 'value': 'All'},
    {'label': 'Cafe', 'icon': Icons.coffee, 'value': 'Cafe'},
    {'label': 'Store', 'icon': Icons.local_convenience_store, 'value': 'Store'},
    {'label': 'Eat', 'icon': Icons.restaurant, 'value': 'Restaurant'},
    {'label': 'Office', 'icon': Icons.account_balance, 'value': 'Admin'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KNU Campus Map'),
        backgroundColor: AppColors.knuRed,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // 1. 네이버 지도
          NaverMap(
            options: const NaverMapViewOptions(
              initialCameraPosition: NCameraPosition(
                target: NLatLng(35.8899, 128.6105),
                zoom: 15,
              ),
              locationButtonEnable: true,
              consumeSymbolTapEvents: false,
            ),
            onMapReady: (controller) {
              _mapController = controller;
              _updateMarkers(); // 초기 마커 로드
            },
          ),

          // 2. 상단 카테고리 선택 바
          Positioned(
            top: 10,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  final isSelected = _selectedCategory == cat['value'];

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: FilterChip(
                      showCheckmark: false,
                      avatar: Icon(
                        cat['icon'],
                        size: 18,
                        color: isSelected ? Colors.white : AppColors.knuRed,
                      ),
                      label: Text(cat['label']),
                      selected: isSelected,
                      onSelected: (bool selected) {
                        setState(() {
                          _selectedCategory = cat['value'];
                        });
                        _updateMarkers(); // 카테고리 변경 시 마커 업데이트
                      },
                      selectedColor: AppColors.knuRed,
                      backgroundColor: Colors.white,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSelected ? AppColors.knuRed : Colors.grey.shade300,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 카테고리에 따라 지도 마커를 업데이트하는 함수
  void _updateMarkers() async {
    // 기존 마커 모두 제거
    await _mapController.clearOverlays();

    // 선택된 카테고리의 데이터 가져오기
    final facilities = _mapService.getFacilitiesByCategory(_selectedCategory);

    for (var facility in facilities) {
      final marker = NMarker(
        id: facility.id,
        position: NLatLng(facility.latitude, facility.longitude),
        caption: NOverlayCaption(text: facility.engName),
      );

      // 마커 클릭 시 상세 정보창 표시
      marker.setOnTapListener((marker) {
        _showFacilityDetail(facility);
      });

      _mapController.addOverlay(marker);
    }
  }

  // 시설 상세 정보 표시 (Bottom Sheet)
  void _showFacilityDetail(Facility facility) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          height: 250,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          facility.engName,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          facility.korName,
                          style: TextStyle(color: Colors.grey[600], fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.knuRed.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      facility.category,
                      style: const TextStyle(color: AppColors.knuRed, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const Divider(height: 30),
              Row(
                children: [
                  const Icon(Icons.info_outline, color: AppColors.knuRed, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      facility.engDesc,
                      style: const TextStyle(fontSize: 15),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // 길찾기 로직 등 추가 가능
                  },
                  icon: const Icon(Icons.directions),
                  label: const Text('Get Directions'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.knuRed,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}