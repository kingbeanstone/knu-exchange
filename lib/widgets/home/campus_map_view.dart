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
  CampusMapViewState createState() => CampusMapViewState();
}

class CampusMapViewState extends State<CampusMapView> {
  NaverMapController? _controller;
  NMarker? _selectedMarker;

  final Set<NMarker> _markers = {};
  final Map<String, Facility> _facilityMap = {};

  final double _captionZoomThreshold = 16.0;
  bool _isCaptionVisible = false;

  // 🔥 HomeScreen에서 호출하는 함수
  void clearSelectedMarker() {
    if (_selectedMarker != null) {
      _selectedMarker!.setSize(const Size(28, 28));
      _selectedMarker = null;
    }
  }

  @override
  void didUpdateWidget(covariant CampusMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.facilities != widget.facilities && _controller != null) {
      _updateMarkers();
    }
  }

  Future<void> _updateMarkers() async {
    if (_controller == null) return;

    await _controller!.clearOverlays();
    _markers.clear();
    _facilityMap.clear();
    _selectedMarker = null;

    for (var f in widget.facilities) {
      final marker = NMarker(
        id: f.id,
        position: NLatLng(f.latitude, f.longitude),
      );

      marker.setIsHideCollidedCaptions(true);
      _facilityMap[f.id] = f;

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

      _markers.add(marker);
      _controller!.addOverlay(marker);
    }

    final cameraPosition = await _controller!.getCameraPosition();
    _updateCaptionByZoom(cameraPosition.zoom);
  }

  void _updateCaptionByZoom(double zoom) {
    final shouldShow = zoom >= _captionZoomThreshold;

    if (_isCaptionVisible == shouldShow) return;
    _isCaptionVisible = shouldShow;

    for (var marker in _markers) {
      final facility = _facilityMap[marker.info.id];
      if (facility == null) continue;

      if (shouldShow) {
        marker.setCaption(
          NOverlayCaption(text: facility.engName),
        );
      } else {
        marker.setCaption(null);
      }
    }
  }

  void _handleMarkerTap(NMarker marker, Facility facility) {
    if (_selectedMarker != null) {
      _selectedMarker!.setSize(const Size(28, 28));
    }

    marker.setSize(const Size(40, 40));
    _selectedMarker = marker;

    _controller?.updateCamera(
      NCameraUpdate.withParams(
        target: NLatLng(facility.latitude, facility.longitude),
      )..setAnimation(
        animation: NCameraAnimation.linear,
        duration: const Duration(milliseconds: 250),
      ),
    );

    widget.onFacilitySelected(facility);
  }

  @override
  Widget build(BuildContext context) {
    return NaverMap(
      options: NaverMapViewOptions(
        initialCameraPosition: NCameraPosition(
          target: widget.initialPosition,
          zoom: 15,
        ),
        locationButtonEnable: false,
      ),
      onMapReady: (controller) {
        _controller = controller;
        widget.onMapReady(controller);
        _updateMarkers();
      },
      onCameraIdle: () async {
        if (_controller == null) return;
        final cameraPosition = await _controller!.getCameraPosition();
        _updateCaptionByZoom(cameraPosition.zoom);
      },
      onMapTapped: (point, latLng) {
        clearSelectedMarker();
      },
      onMapLongTapped: (point, latLng) {
        widget.onMapLongTap?.call(latLng);
      },
    );
  }
}