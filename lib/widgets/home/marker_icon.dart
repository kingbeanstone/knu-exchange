import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

class MarkerIcon extends StatelessWidget {
  final String category;

  const MarkerIcon({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;

    switch (category) {
      case 'Cafe':
        icon = Icons.coffee;
        color = const Color(0xFF8D6E63);
        break;
      case 'Store':
        icon = Icons.local_convenience_store;
        color = const Color(0xFF43A047);
        break;
      case 'Restaurant':
        icon = Icons.restaurant;
        color = const Color(0xFFE53935);
        break;
      case 'Admin':
        icon = Icons.account_balance;
        color = const Color(0xFF1E88E5);
        break;
      default:
        icon = Icons.place;
        color = AppColors.knuRed;
    }

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: 28,
      ),
    );
  }
}