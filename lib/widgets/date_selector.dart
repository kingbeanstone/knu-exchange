import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../utils/app_colors.dart';

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
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: onPrev,
            icon: const Icon(Icons.arrow_back_ios, size: 20),
          ),
      SizedBox(
        height: 52, // 🔥 날짜가 커지니까 약간만 늘림
        child: Column(
          mainAxisAlignment: _isToday(selectedDate)
              ? MainAxisAlignment.start
              : MainAxisAlignment.center,
          children: [
            if (_isToday(selectedDate)) ...[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 7,   // 약간만 늘림
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.knuRed.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  'TODAY',
                  style: TextStyle(
                    fontSize: 12,   // 🔥 10 → 12로 증가
                    fontWeight: FontWeight.w600,
                    color: AppColors.knuRed,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
              const SizedBox(height: 0),
            ],

            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  DateFormat('yyyy-MM-dd').format(selectedDate),
                  style: const TextStyle(
                    fontSize: 17,           // 🔥 크게
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  DateFormat('(EEE)').format(selectedDate),
                  style: const TextStyle(
                    fontSize: 17,           // 🔥 동일하게 크게
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
          IconButton(
            onPressed: onNext,
            icon: const Icon(Icons.arrow_forward_ios, size: 20),
          ),
        ],
      ),
    );
  }
}