import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../utils/app_colors.dart';
import '../../models/facility.dart';
import '../../services/map_service.dart';
import '../../widgets/home/category_filter.dart';
import '../../widgets/home/facility_bottom_sheet.dart';
import '../../widgets/home/map_controls.dart';
import '../../widgets/home/campus_map_view.dart';
import '../../widgets/home/admin_coords_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  NaverMapController? _mapController;
  final MapService _mapService = MapService();
  String _selectedCategory = 'All';

  // 임시 관리자 모드 상태 (추후 정식 관리자 로직으로 교체 예정)
  bool _adminMode = false;
  int _titleTapCount = 0;

  static const _knuCenter = NLatLng(35.8899, 128.6105);

  @override
  Widget build(BuildContext context) {
    final filteredFacilities = _mapService.getFacilitiesByCategory(_selectedCategory);

    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: _handleAdminTap,
          child: const Text('KNU Campus Map'),
        ),
        backgroundColor: AppColors.knuRed,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // 지도 레이어 (리팩토링됨)
          CampusMapView(
            initialPosition: _knuCenter,
            facilities: filteredFacilities,
            onMapReady: (controller) {
              _mapController = controller;
              _initializeLocation();
            },
            onFacilitySelected: _showFacilityDetail,
            onMapLongTap: (latLng) {
              if (_adminMode) _showAdminCoords(latLng);
            },
          ),

          // 카테고리 필터
          Positioned(
            top: 10,
            left: 0,
            right: 0,
            child: CategoryFilter(
              selectedCategory: _selectedCategory,
              onCategorySelected: (category) {
                setState(() => _selectedCategory = category);
              },
            ),
          ),

          // 지도 컨트롤
          Positioned(
            bottom: 24,
            right: 16,
            child: MapControls(
              onResetToKnu: _resetToKnu,
              onMyLocation: _moveToMyLocation,
            ),
          ),
        ],
      ),
    );
  }

  // 위치 권한 초기화
  Future<void> _initializeLocation() async {
    final status = await Permission.location.request();
    if (status.isGranted && _mapController != null) {
      _mapController!.setLocationTrackingMode(NLocationTrackingMode.none);
    }
  }

  // 학교 중심으로 카메라 리셋
  void _resetToKnu() {
    if (_mapController == null) return;
    _mapController!.setLocationTrackingMode(NLocationTrackingMode.none);
    _mapController!.updateCamera(
      NCameraUpdate.withParams(target: _knuCenter, zoom: 15)
        ..setAnimation(animation: NCameraAnimation.easing, duration: const Duration(milliseconds: 500)),
    );
  }

  // 사용자 현재 위치 추적
  void _moveToMyLocation() {
    if (_mapController == null) return;
    _mapController!.setLocationTrackingMode(NLocationTrackingMode.follow);
  }

  // 시설 상세 정보 바텀시트
  void _showFacilityDetail(Facility facility) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => FacilityBottomSheet(facility: facility),
    );
  }

  // [임시] 관리자용 좌표 확인 시트
  void _showAdminCoords(NLatLng latLng) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => AdminCoordsSheet(latLng: latLng),
    );
  }

  // [임시] 관리자 모드 활성화 (5번 터치)
  void _handleAdminTap() {
    _titleTapCount++;
    if (_titleTapCount >= 5) {
      setState(() => _adminMode = !_adminMode);
      _titleTapCount = 0;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_adminMode ? 'Admin Mode Enabled' : 'Admin Mode Disabled'),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }
}