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
import 'providers/fcm_provider.dart';
import './widgets/auth/auth_wrapper.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint("Handling a background message: ${message.messageId}");
}

Future<void> _initFCM() async {
  final messaging = FirebaseMessaging.instance;

  final settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );
  debugPrint('🔔 iOS Notification permission: ${settings.authorizationStatus}');

  await messaging.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  try {
    final apns = await messaging.getAPNSToken();
    debugPrint('📱 APNs token: $apns');
  } catch (_) {}
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1️⃣ Firebase 초기화
  await Firebase.initializeApp();

  // 🔥 디버깅용: FCM 토큰 확인
  final token = await FirebaseMessaging.instance.getToken();
  debugPrint("🔥 FCM TOKEN: $token");

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // iOS 알림 권한 요청
  await _initFCM();

  // 2️⃣ Naver Map 초기화
  await FlutterNaverMap().init(
    clientId: '8px8q0aopz',
    onAuthFailed: (ex) {
      debugPrint("Naver Map Auth Failed: $ex");
    },
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),

        ChangeNotifierProxyProvider<AuthProvider, FavoriteProvider>(
          create: (_) => FavoriteProvider(),
          update: (_, auth, favorite) {
            return favorite!..updateUserId(auth.user?.uid);
          },
        ),

        ChangeNotifierProvider(create: (_) => CommunityProvider()),
        ChangeNotifierProvider(create: (_) => LikeProvider()),
        ChangeNotifierProvider(create: (_) => CommentProvider()),
        ChangeNotifierProvider(create: (_) => MenuProvider()),
        ChangeNotifierProvider(create: (_) => NoticeProvider()),
        ChangeNotifierProvider(create: (_) => ReportProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => FCMProvider()),
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