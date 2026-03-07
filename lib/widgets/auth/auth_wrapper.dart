import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/fcm_provider.dart';
import '../../providers/notification_provider.dart';
import '../../screens/main_screen.dart';
import '../../utils/app_colors.dart';

/// 앱의 인증 상태 및 초기 로딩을 관리하며, 상태 변화에 따른 서비스(FCM, 알림) 초기화를 담당합니다.
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  String? _initializedUid; // 현재 초기화된 사용자의 UID 저장

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    // 1. 초기 인증 정보 및 사용자 데이터를 불러오는 중일 때 (Splash 화면)
    if (authProvider.isInitialLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppColors.knuRed),
              SizedBox(height: 16),
              Text(
                'Checking connection...',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    // 2. 서비스 초기화 및 해제 로직 (Side Effects)
    // build가 호출된 직후 실행되도록 예약합니다.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (authProvider.isAuthenticated) {
        final currentUid = authProvider.user!.uid;

        // UID가 바뀌었을 때만(로그인 혹은 계정 전환 시) 초기화 실행
        if (_initializedUid != currentUid) {
          _initializedUid = currentUid;
          context.read<FCMProvider>().setupFCM(currentUid);
          context.read<NotificationProvider>().initNotifications(currentUid);
        }
      } else {
        // 로그아웃 상태일 때
        if (_initializedUid != null) {
          _initializedUid = null;
          // [추가] 로그아웃 시 알림 리스너를 종료하고 상태를 초기화합니다.
          context.read<NotificationProvider>().disposeNotifications();
        }
      }
    });

    // [중요] 'Guest Mode' 지원을 위해 로그인 여부와 관계없이 메인 화면을 반환합니다.
    return const MainScreen();
  }
}