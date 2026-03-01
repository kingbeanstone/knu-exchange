import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import '../../utils/app_colors.dart';
import '../../models/facility.dart';
import '../../services/map_service.dart';
import '../../widgets/home/category_filter.dart';
import '../../widgets/home/facility_bottom_sheet.dart';
import '../../widgets/home/map_controls.dart';
import '../../widgets/home/campus_map_view.dart';
import '../../widgets/common_notification_button.dart'; // [추가] 공통 알림 버튼 임포트
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

  static const _knuCenter = NLatLng(35.8899, 128.6105);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Facility>>(
      stream: _mapService.getFacilitiesStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return const Scaffold(body: Center(child: Text('Error')));
        if (!snapshot.hasData) return const Scaffold(body: Center(child: CircularProgressIndicator()));

        final allFacilities = snapshot.data!;
        final filteredFacilities = _selectedCategory == 'All'
            ? allFacilities
            : allFacilities.where((f) => f.category == _selectedCategory).toList();

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'KNU Campus Map',
              style: TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 18,
              ),
            ),
            backgroundColor: AppColors.knuRed,
            foregroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            // [수정] 상단바 우측에 알림 버튼 추가
            actions: const [
              CommonNotificationButton(),
              SizedBox(width: 8),
            ],
          ),
          body: Stack(
            children: [
              CampusMapView(
                key: _mapKey,
                initialPosition: _knuCenter,
                facilities: filteredFacilities,
                onMapReady: (controller) => _mapController = controller,
                onFacilitySelected: _showFacilityDetail,
              ),
              Positioned(
                top: 10,
                left: 0,
                right: 0,
                child: CategoryFilter(
                  selectedCategory: _selectedCategory,
                  onCategorySelected: (category) => setState(() => _selectedCategory = category),
                ),
              ),
              Positioned(
                bottom: 24,
                right: 16,
                child: MapControls(
                  onResetToKnu: _resetToKnu,
                  onMyLocation: () => _mapController?.setLocationTrackingMode(NLocationTrackingMode.follow),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _resetToKnu() {
    if (_mapController == null) return;
    _mapController!.updateCamera(
      NCameraUpdate.withParams(target: _knuCenter, zoom: 15)
        ..setAnimation(
            animation: NCameraAnimation.easing,
            duration: const Duration(milliseconds: 500)),
    );
  }

  Future<void> _showFacilityDetail(Facility facility) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) {
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
        );
      },
    ).whenComplete(() {
      _mapKey.currentState?.clearSelectedMarker();
    });
  }
}