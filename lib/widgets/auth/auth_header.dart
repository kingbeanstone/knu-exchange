import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Icon(Icons.account_balance, size: 70, color: AppColors.knuRed),
        const SizedBox(height: 12),
        const Text(
            'KNU EXCHANGE',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.knuRed,
              letterSpacing: 1.2,
            )
        ),
        const SizedBox(height: 32),
        const Text(
          "Welcome back!",
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          "Login to continue your campus life",
          style: TextStyle(color: Colors.grey[600]),
        ),
      ],
    );
  }
}