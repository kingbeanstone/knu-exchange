import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';

// [추가] 서비스 클래스 임포트 (경로를 프로젝트 구조에 맞게 확인하세요)
import 'services/auth_service.dart';
import 'services/community_service.dart';
import 'services/report_service.dart';

import 'providers/favorite_provider.dart';
import 'providers/community_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/like_provider.dart';
import 'providers/comment_provider.dart';
import 'providers/menu_provider.dart';
import 'providers/notice_provider.dart';
import 'providers/report_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/fcm_provider.dart';
import 'providers/feedback_provider.dart';
import './widgets/auth/auth_wrapper.dart';

/// 앱이 종료된 상태에서 알림을 받았을 때 실행되는 백그라운드 핸들러
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await FlutterNaverMap().init(clientId: '8px8q0aopz');

  runApp(
    MultiProvider(
      providers: [
        // 1. [핵심 수정] 일반 서비스 클래스들을 먼저 등록합니다. (PostCard에서 찾을 수 있게 됨)
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<CommunityService>(create: (_) => CommunityService()),
        Provider<ReportService>(create: (_) => ReportService()),

        // 2. 기존 ChangeNotifierProvider들
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, FavoriteProvider>(
          create: (_) => FavoriteProvider(),
          update: (_, auth, favorite) => favorite!..updateUserId(auth.user?.uid),
        ),
        ChangeNotifierProvider(create: (_) => CommunityProvider()),
        ChangeNotifierProvider(create: (_) => LikeProvider()),
        ChangeNotifierProvider(create: (_) => CommentProvider()),
        ChangeNotifierProvider(create: (_) => MenuProvider()),
        ChangeNotifierProvider(create: (_) => NoticeProvider()),
        ChangeNotifierProvider(create: (_) => ReportProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => FCMProvider()),
        ChangeNotifierProvider(create: (_) => FeedbackProvider()),
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
      ),
      home: const AuthWrapper(),
      debugShowCheckedModeBanner: false,
    );
  }
}