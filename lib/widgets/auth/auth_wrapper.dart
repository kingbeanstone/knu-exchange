import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/main_screen.dart';
import '../../utils/app_colors.dart';

/// 앱의 인증 상태를 감시하여 로그인 화면 또는 메인 화면을 자동으로 보여주는 위젯입니다.
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    // 1. 초기 사용자 정보 로드 중일 때 (Splash 화면 역할)
    if (authProvider.isInitialLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppColors.knuRed),
              SizedBox(height: 16),
              Text('인증 정보 확인 중...', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    // 2. 로그인된 경우 메인 화면(탭바가 있는 화면)으로 이동
    if (authProvider.isAuthenticated) {
      return const MainScreen();
    }

    // 3. 로그인되지 않은 경우 로그인 화면으로 이동
    return const LoginScreen();
  }
}