import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../utils/app_colors.dart';

/// 프리미엄 디자인이 적용된 날짜 선택기 위젯
class CafeteriaDateSelector extends StatelessWidget {
  final DateTime selectedDate;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  const CafeteriaDateSelector({
    super.key,
    required this.selectedDate,
    required this.onPrev,
    required this.onNext,
  });

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: onPrev,
            icon: const Icon(Icons.chevron_left_rounded, color: AppColors.knuRed, size: 28),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_isToday(selectedDate))
                Container(
                  margin: const EdgeInsets.only(bottom: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.knuRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'TODAY',
                    style: TextStyle(
                      color: AppColors.knuRed,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              Text(
                DateFormat('yyyy.MM.dd (EEE)').format(selectedDate),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkGrey,
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: onNext,
            icon: const Icon(Icons.chevron_right_rounded, color: AppColors.knuRed, size: 28),
          ),
        ],
      ),
    );
  }
}