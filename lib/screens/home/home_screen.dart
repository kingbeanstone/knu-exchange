import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import '../../utils/app_colors.dart'; // 경로 확인 필요
import 'package:knu_ex/models/facility.dart';
// import '/models/facility.dart';   // 경로 확인 필요

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late NaverMapController _mapController;

  // 교환학생을 위한 필수 장소 데이터 예시
  // 실제로는 MapService 등을 통해 가져오는 것이 좋습니다.
  final List<Map<String, dynamic>> _essentialPlaces = [
    {
      'id': 'global_plaza',
      'korName': '글로벌플라자 (국제교류처)',
      'engName': 'Global Plaza (OIA)',
      'position': const NLatLng(35.8899, 128.6105),
      'desc': 'Office of International Affairs is located here.',
    },
    {
      'id': 'dorm_cheomseong',
      'korName': '첨성관 기숙사',
      'engName': 'Cheomseong-gwan Dorm',
      'position': const NLatLng(35.8864, 128.6145),
      'desc': 'Main dormitory for international students.',
    },
    {
      'id': 'it_4',
      'korName': 'IT융복합관',
      'engName': 'IT Convergence Building',
      'position': const NLatLng(35.8888, 128.6103),
      'desc': 'Major building for Electronics and Mobile Engineering.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KNU Campus Map'),
        backgroundColor: AppColors.knuRed, // app_colors.dart의 색상 사용
        foregroundColor: Colors.white,
      ),
      body: NaverMap(
        options: const NaverMapViewOptions(
          initialCameraPosition: NCameraPosition(
            target: NLatLng(35.8899, 128.6105),
            zoom: 15,
          ),
          locationButtonEnable: true,
        ),
        onMapReady: (controller) {
          _mapController = controller;
          _addEssentialMarkers(); // 마커 추가 함수 호출
        },
      ),
    );
  }

  // 여러 개의 마커를 한꺼번에 추가하는 함수
  void _addEssentialMarkers() {
    for (var place in _essentialPlaces) {
      final marker = NMarker(
        id: place['id'],
        position: place['position'],
        caption: NOverlayCaption(text: place['engName']), // 영어 이름을 캡션으로
      );

      // 마커 클릭 시 상세 정보창(Modal Bottom Sheet) 띄우기
      marker.setOnTapListener((marker) {
        _showPlaceDetail(place);
      });

      _mapController.addOverlay(marker);
    }
  }

  // 하단 상세 정보창 구현
  void _showPlaceDetail(Map<String, dynamic> place) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
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
                          place['engName'],
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          place['korName'],
                          style: TextStyle(color: Colors.grey[600], fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(height: 30),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.info_outline, color: AppColors.knuRed, size: 20),
                  const SizedBox(width: 10),
                  Expanded(child: Text(place['desc'], style: const TextStyle(fontSize: 16))),
                ],
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // 길찾기나 더 자세한 페이지로 이동하는 로직 추가 가능
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.knuRed,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Get Directions'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}