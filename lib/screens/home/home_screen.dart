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

  // 관리자 모드 관련 상태
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
          // 분리된 지도 뷰 위젯
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

          // 카테고리 필터 영역
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

          // 지도 컨트롤 버튼 영역
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

  // --- 비즈니스 로직 ---

  Future<void> _initializeLocation() async {
    final status = await Permission.location.request();
    if (status.isGranted && _mapController != null) {
      _mapController!.setLocationTrackingMode(NLocationTrackingMode.none);
    }
  }

  void _resetToKnu() {
    if (_mapController == null) return;
    _mapController!.setLocationTrackingMode(NLocationTrackingMode.none);
    _mapController!.updateCamera(
      NCameraUpdate.withParams(target: _knuCenter, zoom: 15)
        ..setAnimation(animation: NCameraAnimation.easing, duration: const Duration(milliseconds: 500)),
    );
  }

  // [버그 수정] 내 위치로 이동 로직 강화
  void _moveToMyLocation() {
    if (_mapController == null) return;

void _updateMarkers() async {
  await _mapController.clearOverlays();
  final facilities =
      _mapService.getFacilitiesByCategory(_selectedCategory);

  for (var f in facilities) {
    final marker = NMarker(
      id: f.id,
      position: NLatLng(f.latitude, f.longitude),
      caption: NOverlayCaption(text: f.engName),
    );

    final iconImage = await NOverlayImage.fromWidget(
      widget: MarkerIcon(category: f.category),
      context: context,
      size: const Size(60, 60),
    );

    marker.setIcon(iconImage);
    marker.setSize(const Size(28, 28));

    marker.setOnTapListener((_) {
      _resetSelectedMarkerSize();
      marker.setSize(const Size(44, 44));
      _selectedMarker = marker;

      _mapController.updateCamera(
        NCameraUpdate.withParams(
          target: NLatLng(f.latitude, f.longitude),
        )..setAnimation(
            animation: NCameraAnimation.linear,
            duration: const Duration(milliseconds: 250),
          ),
      );

      _showFacilityDetail(f);
    });

    _mapController.addOverlay(marker);
  }
}

void _resetSelectedMarkerSize() {
  if (_selectedMarker != null) {
    _selectedMarker!.setSize(const Size(28, 28));
    _selectedMarker = null;
  }
}

/// ✅ 내 위치 버튼용 (testing5 코드 분리)
void _moveToMyLocation() {
  _mapController?.setLocationTrackingMode(NLocationTrackingMode.none);
  _mapController?.setLocationTrackingMode(NLocationTrackingMode.follow);
}

  void _showFacilityDetail(Facility facility) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => FacilityBottomSheet(facility: facility),
    );
  }

  void _showAdminCoords(NLatLng latLng) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => AdminCoordsSheet(latLng: latLng),
    );
  }

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