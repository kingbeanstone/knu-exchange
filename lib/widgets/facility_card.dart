import 'package:flutter/material.dart';
import '../models/facility.dart';
import '../utils/app_colors.dart';

class FacilityCard extends StatelessWidget {
  final Facility facility;
  final VoidCallback? onTap;

  const FacilityCard({super.key, required this.facility, this.onTap});

  // 카테고리에 따른 아이콘 반환 함수
  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'admin':
        return Icons.account_balance_outlined;
      case 'dormitory':
        return Icons.hotel_outlined;
      case 'restaurant':
        return Icons.restaurant_outlined;
      case 'bank':
        return Icons.payments_outlined;
      case 'store':
        return Icons.shopping_bag_outlined;
      default:
        return Icons.location_on_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0, // 그림자를 없애고 테두리를 강조하여 더 깔끔한 디자인 적용
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // 왼쪽: 카테고리 아이콘 영역
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.knuRed.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _getCategoryIcon(facility.category),
                  color: AppColors.knuRed,
                ),
              ),
              const SizedBox(width: 16),

              // 중간: 장소 정보 (영어 + 한국어)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      facility.engName, // 교환학생을 위해 영어를 우선 표시
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      facility.korName,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // 오른쪽: 화살표 아이콘
              const Icon(
                Icons.chevron_right,
                color: Colors.grey,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}