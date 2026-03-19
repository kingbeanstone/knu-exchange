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
import 'package:cached_network_image/cached_network_image.dart';

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

        // ✅ [추가] 데이터가 로드되면 즉시 대표 이미지들을 캐싱합니다.
        _precacheFacilityThumbnails(allFacilities);

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

  // ✅ [추가] 대표 이미지 캐싱 함수
  void _precacheFacilityThumbnails(List<Facility> facilities) {
    for (var f in facilities) {
      if (f.imageUrl != null && f.imageUrl!.isNotEmpty) {
        precacheImage(
          CachedNetworkImageProvider(f.imageUrl!),
          context,
        );
      }
    }
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
    // ✅ [추가] 바텀 시트가 열리는 순간, 이 시설의 모든 사진 캐싱 시작
    // 상세 페이지로 넘어가기 전 약 0.5~1초의 시간을 벌 수 있습니다.
    _precacheFacilityInteriorImages(facility);

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

// ✅ [추가] 특정 시설의 전체 사진을 미리 로드하는 함수
  void _precacheFacilityInteriorImages(Facility facility) {
    if (facility.interiorImages != null) {
      for (var url in facility.interiorImages!) {
        if (url.isNotEmpty) {
          precacheImage(CachedNetworkImageProvider(url), context);
        }
      }
    }
  }
}