import 'package:flutter/material.dart';
import '../../models/facility.dart';
import '../../utils/app_colors.dart';

class FacilityDetailScreen extends StatelessWidget {
  final Facility facility;

  const FacilityDetailScreen({super.key, required this.facility});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(facility.engName),
        backgroundColor: AppColors.knuRed,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            facility.engName,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            facility.korName,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.knuRed.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                facility.category,
                style: const TextStyle(
                  color: AppColors.knuRed,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          const Divider(),
          const SizedBox(height: 12),
          Text(
            facility.engDesc,
            style: const TextStyle(fontSize: 16, height: 1.6),
          ),
        ],
      ),
    );
  }
}