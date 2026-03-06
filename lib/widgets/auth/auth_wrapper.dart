import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/fcm_provider.dart';
import '../../providers/notification_provider.dart';
import '../../screens/main_screen.dart';
import '../../utils/app_colors.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

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

    // [수정] 로그인 여부와 상관없이 무조건 MainScreen으로 진입하게 변경합니다.
    // 로그인 페이지는 이제 설정 탭이나 기능 제한 팝업을 통해 접근합니다.
    if (authProvider.isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final userId = authProvider.user!.uid;
        context.read<FCMProvider>().setupFCM(userId);
        context.read<NotificationProvider>().initNotifications(userId);
      });
    }

    return const MainScreen();
  }
}