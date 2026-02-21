import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../utils/app_colors.dart';
import '../../models/facility.dart';
import '../../services/map_service.dart';
import '../../widgets/home/category_filter.dart';
import '../../widgets/home/facility_bottom_sheet.dart';
import '../../widgets/home/map_controls.dart';
import '../../widgets/home/marker_icon.dart';
import '../../widgets/home/admin_coords_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late NaverMapController _mapController;
  final MapService _mapService = MapService();
  String _selectedCategory = 'All';

  bool _adminMode = false;
  int _titleTapCount = 0;
  NMarker? _selectedMarker;

  static const _knuCenter = NLatLng(35.8899, 128.6105);

  @override
  Widget build(BuildContext context) {
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
          NaverMap(
            options: const NaverMapViewOptions(
              initialCameraPosition: NCameraPosition(target: _knuCenter, zoom: 15),
              locationButtonEnable: false, // 커스텀 버튼 사용을 위해 비활성
              consumeSymbolTapEvents: false,
            ),
            onMapReady: (controller) async {
              _mapController = controller;
              await _initializeLocation();
              _updateMarkers();
            },
            onMapLongTapped: (point, latLng) {
              if (_adminMode) _showAdminCoords(latLng);
            },
          ),

          Positioned(
            top: 10,
            left: 0,
            right: 0,
            child: CategoryFilter(
              selectedCategory: _selectedCategory,
              onCategorySelected: (category) {
                setState(() => _selectedCategory = category);
                _updateMarkers();
              },
            ),
          ),

          Positioned(
            bottom: 24,
            right: 16,
            child: MapControls(
              onResetToKnu: _resetToKnu,
              onMyLocation: _moveToMyLocation, // 수정된 함수 연결
            ),
          ),
        ],
      ),
    );
  }

  // 내 위치로 이동 및 Follow 모드 고정 로직
  Future<void> _moveToMyLocation() async {
    final status = await Permission.location.status;
    if (!status.isGranted) {
      await Permission.location.request();
      return;
    }

    // [수정] setLocationTrackingMode는 void를 반환하므로 await를 제거합니다.
    // 모드를 강제로 재설정하여 현재 위치로 카메라를 즉시 이동시킵니다.
    // 이미 follow 모드인 경우에도 다시 snap 하도록 하기 위해 none 후 follow를 호출합니다.
    _mapController.setLocationTrackingMode(NLocationTrackingMode.none);
    _mapController.setLocationTrackingMode(NLocationTrackingMode.follow);
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

  void _showAdminCoords(NLatLng latLng) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => AdminCoordsSheet(latLng: latLng),
    );
  }

  void _resetToKnu() {
    // 학교 중심으로 돌아갈 때는 위치 추적 해제
    _mapController.setLocationTrackingMode(NLocationTrackingMode.none);
    _mapController.updateCamera(
      NCameraUpdate.withParams(target: _knuCenter, zoom: 15)
        ..setAnimation(animation: NCameraAnimation.easing, duration: const Duration(milliseconds: 500)),
    );
  }

  Future<void> _initializeLocation() async {
    final status = await Permission.location.request();
    if (status.isGranted) {
      _mapController.setLocationTrackingMode(NLocationTrackingMode.none);
    }
  }

  void _updateMarkers() async {
    await _mapController.clearOverlays();
    final facilities = _mapService.getFacilitiesByCategory(_selectedCategory);

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
      marker.setSize(const Size(36, 36));

      marker.setOnTapListener((_) {
        _resetSelectedMarkerSize();
        marker.setSize(const Size(50, 50));
        _selectedMarker = marker;
        _mapController.updateCamera(
          NCameraUpdate.withParams(target: NLatLng(f.latitude, f.longitude), zoom: 16)
            ..setAnimation(animation: NCameraAnimation.linear, duration: const Duration(milliseconds: 250)),
        );
        _showFacilityDetail(f);
      });
      _mapController.addOverlay(marker);
    }
  }

  void _resetSelectedMarkerSize() {
    if (_selectedMarker != null) {
      _selectedMarker!.setSize(const Size(36, 36));
      _selectedMarker = null;
    }
  }

  void _showFacilityDetail(Facility facility) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => FacilityBottomSheet(facility: facility),
    ).whenComplete(() => _resetSelectedMarkerSize());
  }
}