import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';

// �꽌鍮꾩뒪 諛� �봽濡쒕컮�씠�뜑 �엫�룷�듃
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
import 'providers/fcm_provider.dart'; // [異붽��] FCM �봽濡쒕컮�씠�뜑
import './widgets/auth/auth_wrapper.dart';
//import 'firebase_options.dart'; // firebase_options �뙆�씪�씠 �엳�떎硫� �엫�룷�듃

/// 諛깃렇�씪�슫�뱶�뿉�꽌 �븣由� �닔�떊 �떆 濡쒖쭅 (理쒖긽�떒 �쐞移� �븘�닔)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint("Handling a background message: ${message.messageId}");
}

Future<void> _initFCM() async {
  final messaging = FirebaseMessaging.instance;

  // iOS: 沅뚰븳 �슂泥��쓣 �븳 踰덈룄 �븯吏� �븡�쑝硫�, �꽕�젙 �빋�뿉 '�븣由�' 硫붾돱 �옄泥닿�� �븞 �쑚�땲�떎.
  final settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );
  debugPrint('�윍� iOS Notification permission: ${settings.authorizationStatus}');

  // iOS: �룷洹몃씪�슫�뱶�뿉�꽌�룄 �븣由� �몴�떆 (�븘�슂 �떆)
  await messaging.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  // �뵒踰꾧렇�슜 (iOS�뿉�꽌 APNs �넗�겙�씠 �옒 �깮�꽦�릺�뒗吏� �솗�씤)
  try {
    final apns = await messaging.getAPNSToken();
    debugPrint('�윂� APNs token: $apns');
  } catch (_) {}
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Firebase 珥덇린�솕 諛� FCM 諛깃렇�씪�슫�뱶 �빖�뱾�윭 �벑濡�
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // iOS �븣由� 沅뚰븳 �슂泥� (�씠寃� �뾾�쑝硫� iPhone�뿉�꽌 �븣由� 沅뚰븳李�/�꽕�젙 硫붾돱媛� �븞 �쑚�땲�떎)
  await _initFCM();

  // 2. Naver Map 珥덇린�솕
  await FlutterNaverMap().init(
    clientId: '8px8q0aopz',
    onAuthFailed: (ex) {
      debugPrint("Naver Map Auth Failed: $ex");
    },
  );

  runApp(
    MultiProvider(
      providers: [
        // AuthProvider瑜� 理쒖긽�떒�뿉 諛곗튂
        ChangeNotifierProvider(create: (_) => AuthProvider()),

        // AuthProvider瑜� 李몄“�븯�뒗 FavoriteProvider (ProxyProvider)
        ChangeNotifierProxyProvider<AuthProvider, FavoriteProvider>(
          create: (_) => FavoriteProvider(),
          update: (_, auth, favorite) {
            return favorite!..updateUserId(auth.user?.uid);
          },
        ),

        // �굹癒몄�� �봽濡쒕컮�씠�뜑�뱾
        ChangeNotifierProvider(create: (_) => CommunityProvider()),
        ChangeNotifierProvider(create: (_) => LikeProvider()),
        ChangeNotifierProvider(create: (_) => CommentProvider()),
        ChangeNotifierProvider(create: (_) => MenuProvider()),
        ChangeNotifierProvider(create: (_) => NoticeProvider()),
        ChangeNotifierProvider(create: (_) => ReportProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => FCMProvider()), // [異붽��] FCM �봽濡쒕컮�씠�뜑 �벑濡�
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
        // �룿�듃 �꽕�젙�씠 �븘�슂�븯�떎硫� 異붽�� (�삁: fontFamily: 'Pretendard')
      ),
      home: const AuthWrapper(),
      debugShowCheckedModeBanner: false,
    );
  }
}