import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'screens/main_screen.dart';
import 'providers/favorite_provider.dart';
import 'providers/community_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/like_provider.dart';
import 'providers/comment_provider.dart';
import 'providers/menu_provider.dart';
import 'providers/notice_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  await FlutterNaverMap().init(
    clientId: '8px8q0aopz',
    onAuthFailed: (ex) {
      debugPrint("Naver Map Auth Failed: $ex");
    },
  );

  runApp(
    MultiProvider(
      providers: [
        // 1. AuthProvider를 최상단에 배치하여 다른 프로바이더들이 참조할 수 있게 합니다.
        ChangeNotifierProvider(create: (_) => AuthProvider()),

        // 2. FavoriteProvider를 ProxyProvider로 변경하여 AuthProvider의 유저 정보를 감시합니다.
        ChangeNotifierProxyProvider<AuthProvider, FavoriteProvider>(
          create: (_) => FavoriteProvider(),
          update: (_, auth, favorite) {
            // AuthProvider의 user.uid가 변경될 때마다 FavoriteProvider 내부 상태를 업데이트합니다.
            return favorite!..updateUserId(auth.user?.uid);
          },
        ),

        // 3. 나머지 프로바이더들 등록
        ChangeNotifierProvider(create: (_) => CommunityProvider()),
        ChangeNotifierProvider(create: (_) => LikeProvider()),
        ChangeNotifierProvider(create: (_) => CommentProvider()),
        ChangeNotifierProvider(create: (_) => MenuProvider()),
        ChangeNotifierProvider(create: (_) => NoticeProvider()),
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
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}