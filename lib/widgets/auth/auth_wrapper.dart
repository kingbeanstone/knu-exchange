import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/main_screen.dart';
import '../../utils/app_colors.dart';

/// A widget that monitors the app's authentication state to automatically
/// show either the login screen or the main screen.
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    // 1. When the initial user information is being loaded (Splash screen role)
    if (authProvider.isInitialLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppColors.knuRed),
              SizedBox(height: 16),
              Text('Verifying authentication...', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    // 2. If logged in, navigate to the main screen (screen with the tab bar)
    if (authProvider.isAuthenticated) {
      return const MainScreen();
    }

    // 3. If not logged in, navigate to the login screen
    return const LoginScreen();
  }
}