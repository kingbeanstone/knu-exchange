import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: onPrev,
            icon: const Icon(Icons.arrow_back_ios, size: 20),
          ),
          Column(
            children: [
              Text(
                DateFormat('EEEE').format(selectedDate),
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              Text(
                DateFormat('yyyy-MM-dd').format(selectedDate),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
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