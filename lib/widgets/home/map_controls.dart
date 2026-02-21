import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

class MapControls extends StatelessWidget {
  final VoidCallback onResetToKnu;
  final VoidCallback onMyLocation; // 이름 변경: 토글에서 내 위치 이동으로

  const MapControls({
    super.key,
    required this.onResetToKnu,
    required this.onMyLocation,
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
        // 내 위치 이동 버튼 (항상 Follow 모드로 작동)
        FloatingActionButton.small(
          heroTag: 'location_move_btn',
          onPressed: onMyLocation,
          backgroundColor: Colors.white,
          foregroundColor: AppColors.knuRed,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: const Icon(Icons.my_location), // 고정 아이콘 사용
        ),
      ],
    );
  }
}