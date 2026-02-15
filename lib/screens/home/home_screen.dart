import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:provider/provider.dart';

import '../../models/facility.dart';
import '../../providers/favorite_provider.dart';
import '../../services/map_service.dart';
import '../../utils/app_colors.dart';
import '../cafeteria/cafeteria_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late NaverMapController _mapController;
  final MapService _mapService = MapService();

  // Current selected category (All, Cafe, Store, Restaurant, Admin)
  String _selectedCategory = 'All';

  // Hidden admin mode (tap the title 5 times)
  bool _adminMode = false;
  int _titleTapCount = 0;

  final List<Map<String, dynamic>> _categories = [
    {'label': 'All', 'icon': Icons.map, 'value': 'All'},
    {'label': 'Cafe', 'icon': Icons.coffee, 'value': 'Cafe'},
    {'label': 'Store', 'icon': Icons.local_convenience_store, 'value': 'Store'},
    {'label': 'Cafeteria', 'icon': Icons.restaurant, 'value': 'Restaurant'},
    {'label': 'Office', 'icon': Icons.account_balance, 'value': 'Admin'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () {
            _titleTapCount++;
            if (_titleTapCount >= 5) {
              setState(() {
                _adminMode = !_adminMode;
              });
              _titleTapCount = 0;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    _adminMode ? 'Admin Mode Enabled' : 'Admin Mode Disabled',
                  ),
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
            onMapReady: (controller) {
              _mapController = controller;
              _updateMarkers();
            },
            onMapLongTapped: (point, latLng) {
              if (!_adminMode) return;

              showModalBottomSheet(
                context: context,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (context) {
                  final lat = latLng.latitude;
                  final lng = latLng.longitude;
                  final text = '$lat, $lng';

                  return Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Selected Coordinates',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.knuRed.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: const Text(
                                'ADMIN',
                                style: TextStyle(
                                  color: AppColors.knuRed,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text('lat: $lat', style: const TextStyle(fontSize: 15)),
                        Text('lng: $lng', style: const TextStyle(fontSize: 15)),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.knuRed,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: text));
                              Navigator.pop(context);
                              ScaffoldMessenger.of(this.context).showSnackBar(
                                const SnackBar(
                                  content: Text('Copied to clipboard'),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            },
                            icon: const Icon(Icons.copy),
                            label: const Text('Copy to Clipboard'),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Tip: Paste into map_service.dart as latitude/longitude.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),

          Positioned(
            top: 10,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  final isSelected = _selectedCategory == cat['value'];

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: FilterChip(
                      showCheckmark: false,
                      avatar: Icon(
                        cat['icon'],
                        size: 18,
                        color: isSelected ? Colors.white : AppColors.knuRed,
                      ),
                      label: Text(cat['label']),
                      selected: isSelected,
                      onSelected: (bool selected) {
                        setState(() {
                          _selectedCategory = cat['value'];
                        });
                        _updateMarkers();
                      },
                      selectedColor: AppColors.knuRed,
                      backgroundColor: Colors.white,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSelected ? AppColors.knuRed : Colors.grey.shade300,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _updateMarkers() async {
    await _mapController.clearOverlays();

    final facilities = _mapService.getFacilitiesByCategory(_selectedCategory);

    for (final facility in facilities) {
      final marker = NMarker(
        id: facility.id,
        position: NLatLng(facility.latitude, facility.longitude),
        caption: NOverlayCaption(text: facility.engName),
      );

      // ✅ 아이콘 마커(위젯)로 만들기 (PNG 필요 없음)
      final overlayIcon = await NOverlayImage.fromWidget(
        widget: _MarkerIcon(
          icon: _iconForCategory(facility.category),
          backgroundColor: _bgForCategory(facility.category),
        ),
        context: context,
        size: const Size(70, 70), // 렌더링 캔버스 크기(여유)
      );

      marker.setIcon(overlayIcon);
      marker.setSize(const Size(36, 36)); // 지도 위 실제 표시 크기

      marker.setOnTapListener((marker) {
        _showFacilityDetail(facility);
      });

      _mapController.addOverlay(marker);
    }
  }

  IconData _iconForCategory(String category) {
    switch (category) {
      case 'Cafe':
        return Icons.coffee;
      case 'Store':
        return Icons.local_convenience_store;
      case 'Restaurant':
        return Icons.restaurant;
      case 'Admin':
        return Icons.account_balance;
      default:
        return Icons.place;
    }
  }

  Color _bgForCategory(String category) {
    switch (category) {
      case 'Cafe':
        return const Color(0xFF8D6E63);
      case 'Store':
        return const Color(0xFF43A047);
      case 'Restaurant':
        return const Color(0xFFE53935);
      case 'Admin':
        return const Color(0xFF1E88E5);
      default:
        return const Color(0xFF616161);
    }
  }




  void _showFacilityDetail(Facility facility) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Consumer<FavoriteProvider>(
          builder: (context, favoriteProvider, child) {
            final bool isFav = favoriteProvider.isFavorite(facility.id);

            return Container(
              padding: const EdgeInsets.all(24),
              height: 250,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              facility.engName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              facility.korName,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          isFav ? Icons.star : Icons.star_border,
                          color: isFav ? Colors.red : Colors.grey,
                          size: 28,
                        ),
                        onPressed: () {
                          favoriteProvider.toggleFavorite(facility.id);
                        },
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.knuRed.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          facility.category,
                          style: const TextStyle(
                            color: AppColors.knuRed,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 30),
                  Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: AppColors.knuRed,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          facility.engDesc,
                          style: const TextStyle(fontSize: 15),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);

                        if (facility.category == 'Restaurant') {
                          Navigator.of(this.context).push(
                            MaterialPageRoute(
                              builder: (_) => CafeteriaScreen(
                                initialFacilityId: facility.id,
                              ),
                            ),
                          );
                          return;
                        }

                        // TODO: Add directions/navigation later
                      },
                      icon: Icon(
                        facility.category == 'Restaurant'
                            ? Icons.restaurant_menu
                            : Icons.directions,
                      ),
                      label: Text(
                        facility.category == 'Restaurant'
                            ? 'View Menu'
                            : 'Get Directions',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.knuRed,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _MarkerIcon extends StatelessWidget {
  final IconData icon;
  final Color backgroundColor;

  const _MarkerIcon({
    Key? key,
    required this.icon,
    required this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: 30,
      ),
    );
  }
}
