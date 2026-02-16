import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../utils/app_colors.dart';
import '../../models/facility.dart';
import '../../services/map_service.dart';
import '../../widgets/category_filter.dart';
import '../../widgets/facility_bottom_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late NaverMapController _mapController;
  final MapService _mapService = MapService();
  String _selectedCategory = 'All';

  // 어드민 모드 로직 복구
  bool _adminMode = false;
  int _titleTapCount = 0;
  NMarker? _selectedMarker;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () {
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
          },
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
              initialCameraPosition: NCameraPosition(
                target: NLatLng(35.8899, 128.6105),
                zoom: 15,
              ),
              locationButtonEnable: true,
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
        ],
      ),
    );
  }

  Future<void> _initializeLocation() async {
    final status = await Permission.location.request();
    if (status.isGranted) {
      _mapController.setLocationTrackingMode(NLocationTrackingMode.follow);
    }
  }

  // 어드민 좌표 복사 바텀시트
  void _showAdminCoords(NLatLng latLng) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Selected Coordinates', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text('lat: ${latLng.latitude}'),
            Text('lng: ${latLng.longitude}'),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: '${latLng.latitude}, ${latLng.longitude}'));
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied to clipboard')));
                },
                icon: const Icon(Icons.copy),
                label: const Text('Copy to Clipboard'),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.knuRed, foregroundColor: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
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

      // 위젯 마커 로직 복구
      final iconImage = await NOverlayImage.fromWidget(
        widget: _MarkerIcon(category: f.category),
        context: context,
        size: const Size(60, 60),
      );
      marker.setIcon(iconImage);
      marker.setSize(const Size(36, 36));

      marker.setOnTapListener((_) {
        // 선택 시 마커 크기 키우고 카메라 이동
        _resetSelectedMarkerSize();
        marker.setSize(const Size(50, 50));
        _selectedMarker = marker;

        _mapController.updateCamera(
            NCameraUpdate.withParams(
              target: NLatLng(f.latitude, f.longitude),
              zoom: 16,
            )..setAnimation(animation: NCameraAnimation.linear, duration: const Duration(milliseconds: 250))
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

// 카테고리별 마커 아이콘 위젯
class _MarkerIcon extends StatelessWidget {
  final String category;
  const _MarkerIcon({required this.category});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;
    switch (category) {
      case 'Cafe': icon = Icons.coffee; color = const Color(0xFF8D6E63); break;
      case 'Store': icon = Icons.local_convenience_store; color = const Color(0xFF43A047); break;
      case 'Restaurant': icon = Icons.restaurant; color = const Color(0xFFE53935); break;
      case 'Admin': icon = Icons.account_balance; color = const Color(0xFF1E88E5); break;
      default: icon = Icons.place; color = AppColors.knuRed;
    }
    return Container(
      width: 48, height: 48,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle, boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))]),
      child: Icon(icon, color: Colors.white, size: 28),
    );
  }
}