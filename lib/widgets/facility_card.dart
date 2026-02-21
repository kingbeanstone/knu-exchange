import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/facility.dart';
import '../utils/app_colors.dart';
import '../providers/favorite_provider.dart';
import '../providers/auth_provider.dart';
import '../screens/auth/login_screen.dart';

class FacilityCard extends StatelessWidget {
  final Facility facility;
  final VoidCallback? onTap;

  const FacilityCard({super.key, required this.facility, this.onTap});

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'admin': return Icons.account_balance_outlined;
      case 'dormitory': return Icons.hotel_outlined;
      case 'restaurant': return Icons.restaurant_outlined;
      case 'bank': return Icons.payments_outlined;
      case 'store': return Icons.shopping_bag_outlined;
      case 'cafe': return Icons.coffee_outlined;
      default: return Icons.location_on_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    // FavoriteProvider를 구독하여 실시간 반영
    final favoriteProvider = Provider.of<FavoriteProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final bool isFav = favoriteProvider.isFavorite(facility.id);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.knuRed.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(_getCategoryIcon(facility.category), color: AppColors.knuRed),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(facility.engName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(facility.korName, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  if (!authProvider.isAuthenticated) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text("Log in is required to save favorites."),
                        action: SnackBarAction(
                          label: "Login",
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen())),
                        ),
                      ),
                    );
                    return;
                  }
                  favoriteProvider.toggleFavorite(facility.id);
                },
                icon: Icon(
                  isFav ? Icons.favorite : Icons.favorite_border,
                  color: isFav ? AppColors.knuRed : Colors.grey[400],
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