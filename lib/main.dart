import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';

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
import 'providers/feedback_provider.dart'; // [추가]
import './widgets/auth/auth_wrapper.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  await FlutterNaverMap().init(clientId: '8px8q0aopz');

  runApp(
    MultiProvider(
      providers: [
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
        ChangeNotifierProvider(create: (_) => FeedbackProvider()), // [추가]
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