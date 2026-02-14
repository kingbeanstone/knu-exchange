import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'screens/main_screen.dart';
import 'package:provider/provider.dart';
import 'providers/favorite_provider.dart';
import 'providers/community_provider.dart'; // 추가
import 'package:firebase_core/firebase_core.dart';
import 'providers/auth_provider.dart';
import 'providers/like_provider.dart';
import 'providers/comment_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  await FlutterNaverMap().init(
    clientId: '8px8q0aopz',
    onAuthFailed: (ex) {
      print("Naver Map Auth Failed: $ex");
    },
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FavoriteProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CommunityProvider()), // 커뮤니티 프로바이더 등록
        ChangeNotifierProvider(create: (_) => LikeProvider()),
        ChangeNotifierProvider(create: (_) => CommentProvider()),
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