import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';

// 서비스 및 프로바이더 임포트
import 'screens/main_screen.dart';
import 'providers/favorite_provider.dart';
import 'providers/community_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/like_provider.dart';
import 'providers/comment_provider.dart';
import 'providers/menu_provider.dart';
import 'providers/notice_provider.dart';
import 'providers/report_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/fcm_provider.dart'; // [추가] FCM 프로바이더
import './widgets/auth/auth_wrapper.dart';
//import 'firebase_options.dart'; // firebase_options 파일이 있다면 임포트

/// 백그라운드에서 알림 수신 시 로직 (최상단 위치 필수)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Firebase 초기화 및 FCM 백그라운드 핸들러 등록
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // 2. Naver Map 초기화
  await FlutterNaverMap().init(
    clientId: '8px8q0aopz',
    onAuthFailed: (ex) {
      debugPrint("Naver Map Auth Failed: $ex");
    },
  );

  runApp(
    MultiProvider(
      providers: [
        // AuthProvider를 최상단에 배치
        ChangeNotifierProvider(create: (_) => AuthProvider()),

        // AuthProvider를 참조하는 FavoriteProvider (ProxyProvider)
        ChangeNotifierProxyProvider<AuthProvider, FavoriteProvider>(
          create: (_) => FavoriteProvider(),
          update: (_, auth, favorite) {
            return favorite!..updateUserId(auth.user?.uid);
          },
        ),

        // 나머지 프로바이더들
        ChangeNotifierProvider(create: (_) => CommunityProvider()),
        ChangeNotifierProvider(create: (_) => LikeProvider()),
        ChangeNotifierProvider(create: (_) => CommentProvider()),
        ChangeNotifierProvider(create: (_) => MenuProvider()),
        ChangeNotifierProvider(create: (_) => NoticeProvider()),
        ChangeNotifierProvider(create: (_) => ReportProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => FCMProvider()), // [추가] FCM 프로바이더 등록
      ],
      child: const KnuExApp(),
    ),
  );
}

class KnuExApp extends StatelessWidget {
  const KnuExApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KNU Exchange',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFDD1829)),
        // 폰트 설정이 필요하다면 추가 (예: fontFamily: 'Pretendard')
      ),
      home: const AuthWrapper(),
      debugShowCheckedModeBanner: false,
    );
  }
}