import 'package:flutter/material.dart';
import '../../../models/facility.dart';
import '../../../utils/app_colors.dart';

class FacilityBottomSheet extends StatelessWidget {
  final Facility facility;
  final VoidCallback onMoreInfo;
  final VoidCallback? onViewMenu;

  const FacilityBottomSheet({
    super.key,
    required this.facility,
    required this.onMoreInfo,
    this.onViewMenu,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
                  color: AppColors.knuRed.withOpacity(0.1),
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
          Text(
            facility.engDesc,
            style: const TextStyle(fontSize: 15, height: 1.5),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onMoreInfo,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.knuRed,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('More Info'),
            ),
          ),
          if (onViewMenu != null) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onViewMenu,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.knuRed,
                  side: const BorderSide(color: AppColors.knuRed),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('View Menu'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}