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
  State<CampusMapView> createState() => CampusMapViewState();
}

class CampusMapViewState extends State<CampusMapView> {
  NaverMapController? _controller;
  NMarker? _selectedMarker;

  void clearSelectedMarker() {
    if (_selectedMarker != null) {
      _selectedMarker!.setSize(const Size(28, 28)); // 기본 크기(네가 쓰던 값)
      _selectedMarker = null;
    }
  }

  @override
  void didUpdateWidget(CampusMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 표시할 시설 데이터가 변경되면 마커를 갱신합니다.
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

      // 커스텀 위젯을 마커 아이콘으로 변환
      if (!mounted) return;

      final iconImage = await NOverlayImage.fromWidget(
        widget: MarkerIcon(category: f.category),
        context: context,
        size: const Size(28, 28),
      );

      if (!mounted) return;

      marker.setIcon(iconImage);

      marker.setOnTapListener((overlay) {
        _handleMarkerTap(marker, f);
      });

      _controller!.addOverlay(marker);
    }
  }

  void _handleMarkerTap(NMarker marker, Facility facility) {
    // 이전 선택 마커 크기 초기화
    if (_selectedMarker != null) {
      _selectedMarker!.setSize(const Size(28, 28));
    }

    // 새 마커 강조 및 저장
    marker.setSize(const Size(40, 40));
    _selectedMarker = marker;

    // 카메라 이동
    _controller!.updateCamera(
      NCameraUpdate.withParams(
        target: NLatLng(facility.latitude, facility.longitude),
      )..setAnimation(animation: NCameraAnimation.linear, duration: const Duration(milliseconds: 250)),
    );

    // HomeScreen으로 선택된 시설 전달
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
      onMapTapped: (point, latLng) {
        if (_selectedMarker != null) {
          _selectedMarker!.setSize(const Size(28, 28));
          _selectedMarker = null;
        }
      },
    );
  }
}