import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import '../../models/facility.dart';
import './marker_icon.dart';

class CampusMapView extends StatefulWidget {
  final NLatLng initialPosition;
  final List<Facility> facilities;
  final Function(NaverMapController) onMapReady;
  final Function(Facility) onFacilitySelected;
  final Function(NLatLng)? onMapLongTap;

  const CampusMapView({
    super.key,
    required this.initialPosition,
    required this.facilities,
    required this.onMapReady,
    required this.onFacilitySelected,
    this.onMapLongTap,
  });

  @override
  State<CampusMapView> createState() => _CampusMapViewState();
}

class _CampusMapViewState extends State<CampusMapView> {
  NaverMapController? _controller;
  NMarker? _selectedMarker;

  @override
  void didUpdateWidget(CampusMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 시설 데이터가 변경되면 마커를 새로 그립니다.
    if (oldWidget.facilities != widget.facilities && _controller != null) {
      _updateMarkers();
    }
  }

  Future<void> _updateMarkers() async {
    if (_controller == null) return;

    await _controller!.clearOverlays();
    _selectedMarker = null;

    for (var f in widget.facilities) {
      final marker = NMarker(
        id: f.id,
        position: NLatLng(f.latitude, f.longitude),
        caption: NOverlayCaption(text: f.engName),
      );

      // 커스텀 위젯 아이콘 생성
      final iconImage = await NOverlayImage.fromWidget(
        widget: MarkerIcon(category: f.category),
        context: context,
        size: const Size(60, 60),
      );

      marker.setIcon(iconImage);
      marker.setSize(const Size(36, 36));

      marker.setOnTapListener((_) {
        _handleMarkerTap(marker, f);
      });

      _controller!.addOverlay(marker);
    }
  }

  void _handleMarkerTap(NMarker marker, Facility facility) {
    // 이전 선택된 마커 크기 원복
    if (_selectedMarker != null) {
      _selectedMarker!.setSize(const Size(36, 36));
    }

    // 선택된 마커 강조
    marker.setSize(const Size(50, 50));
    _selectedMarker = marker;

    // 카메라 이동
    _controller!.updateCamera(
      NCameraUpdate.withParams(
        target: NLatLng(facility.latitude, facility.longitude),
        zoom: 16,
      )..setAnimation(animation: NCameraAnimation.linear, duration: const Duration(milliseconds: 250)),
    );

    // 부모 위젯(HomeScreen)에 선택 알림
    widget.onFacilitySelected(facility);
  }

  @override
  Widget build(BuildContext context) {
    return NaverMap(
      options: NaverMapViewOptions(
        initialCameraPosition: NCameraPosition(target: widget.initialPosition, zoom: 15),
        locationButtonEnable: false,
        consumeSymbolTapEvents: false,
      ),
      onMapReady: (controller) {
        _controller = controller;
        widget.onMapReady(controller);
        _updateMarkers();
      },
      onMapLongTapped: (point, latLng) {
        if (widget.onMapLongTap != null) {
          widget.onMapLongTap!(latLng);
        }
      },
    );
  }
}