import 'package:flutter/material.dart';
import '../models/facility.dart';
import '../utils/app_colors.dart';

class FacilityCard extends StatefulWidget {
  final Facility facility;
  final VoidCallback? onTap;

  const FacilityCard({super.key, required this.facility, this.onTap});

  @override
  State<FacilityCard> createState() => _FacilityCardState();
}

class _FacilityCardState extends State<FacilityCard> {
  // 실제로는 전역 상태나 DB를 확인해야 하지만, 현재는 로컬 상태로 구현합니다.
  bool isFavorited = true;

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
      case 'cafe':
        return Icons.coffee_outlined;
      default:
        return Icons.location_on_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // 왼쪽: 카테고리 아이콘
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.knuRed.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getCategoryIcon(widget.facility.category),
                  color: AppColors.knuRed,
                ),
              ),
              const SizedBox(width: 16),

              // 중간: 장소 정보
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.facility.engName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.facility.korName,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              // 오른쪽: 즐겨찾기 토글 버튼
              IconButton(
                onPressed: () {
                  setState(() {
                    isFavorited = !isFavorited;
                  });
                  // 여기에 실제 즐겨찾기 리스트에서 추가/삭제하는 로직 추가
                },
                icon: Icon(
                  isFavorited ? Icons.favorite : Icons.favorite_border,
                  color: isFavorited ? AppColors.knuRed : Colors.grey[400],
                  size: 24,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}