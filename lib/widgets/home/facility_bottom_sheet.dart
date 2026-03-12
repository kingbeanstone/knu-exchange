import 'package:flutter/material.dart';
import '../../../models/facility.dart';
import '../../../utils/app_colors.dart';

class FacilityBottomSheet extends StatelessWidget {
  final Facility facility;
  final VoidCallback onMoreInfo;

  const FacilityBottomSheet({
    super.key,
    required this.facility,
    required this.onMoreInfo,
  });

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    return Container(
      // 1. 하단 시트의 전체 높이를 화면의 45% 정도로 고정 (원하는 높이로 조절 가능)
      height: screenHeight * 0.30,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 상단 제목 섹션 (고정)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      facility.engName,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      facility.korName,
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.knuRed.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  facility.category,
                  style: const TextStyle(color: AppColors.knuRed, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const Divider(height: 32),

          // 2. 내용 섹션 (스크롤 가능하도록 Expanded + SingleChildScrollView 적용)
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(), // 부드러운 스크롤 효과
              child: Text(
                facility.engDesc,
                style: const TextStyle(fontSize: 15, height: 1.5),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 하단 버튼 섹션 (고정)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onMoreInfo,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.knuRed,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('More Info'),
            ),
          ),
        ],
      ),
    );
  }
}