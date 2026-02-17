import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import '../../utils/app_colors.dart';

class MapControls extends StatelessWidget {
  final VoidCallback onResetToKnu;
  final VoidCallback onToggleLocation;
  final NLocationTrackingMode currentMode;

  const MapControls({
    super.key,
    required this.onResetToKnu,
    required this.onToggleLocation,
    required this.currentMode,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 경북대학교 중심 이동 버튼
        FloatingActionButton.small(
          heroTag: 'knu_reset_btn',
          onPressed: onResetToKnu,
          backgroundColor: Colors.white,
          foregroundColor: AppColors.knuRed,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: const Icon(Icons.school),
        ),
        const SizedBox(height: 12),
        // 커스텀 내 위치 버튼 (Follow와 Face 모드만 토글)
        FloatingActionButton.small(
          heroTag: 'location_toggle_btn',
          onPressed: onToggleLocation,
          backgroundColor: Colors.white,
          foregroundColor: currentMode == NLocationTrackingMode.none
              ? Colors.grey
              : AppColors.knuRed,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Icon(_getIconForMode()),
        ),
      ],
    );
  }

  // 현재 모드에 따른 아이콘 변경
  IconData _getIconForMode() {
    switch (currentMode) {
      case NLocationTrackingMode.follow:
        return Icons.navigation; // 화살표
      case NLocationTrackingMode.face:
        return Icons.explore; // 나침반/부채꼴 느낌
      default:
        return Icons.my_location; // 기본 위치 아이콘
    }
  }
}