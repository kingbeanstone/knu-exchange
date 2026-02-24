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
import 'facility_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  final void Function(String facilityId) onGoToCafeteria;

  const HomeScreen({
    super.key,
    required this.onGoToCafeteria,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<CampusMapViewState> _mapKey = GlobalKey<CampusMapViewState>();
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
          CampusMapView(
            key: _mapKey,
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

  void _moveToMyLocation() {
    if (_mapController == null) return;
    _mapController!.setLocationTrackingMode(NLocationTrackingMode.none);
    _mapController!.setLocationTrackingMode(NLocationTrackingMode.follow);
  }

  Future<void> _showFacilityDetail(Facility facility) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true, // 내부 콘텐츠 크기에 맞게 조절되도록 설정
      useSafeArea: true, // 시스템 세이프 에어리어를 고려하도록 설정
      builder: (sheetContext) {
        final bool isCafeteria = facility.category == 'Restaurant';

        return FacilityBottomSheet(
          facility: facility,
          onMoreInfo: () {
            Navigator.pop(sheetContext);
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => FacilityDetailScreen(facility: facility),
              ),
            );
          },
          onViewMenu: isCafeteria
              ? () {
            Navigator.pop(sheetContext);
            widget.onGoToCafeteria(facility.id);
          }
              : null,
        );
      },
    ).whenComplete(() {
      _mapKey.currentState?.clearSelectedMarker();
    });
  }

  void _showAdminCoords(NLatLng latLng) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
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