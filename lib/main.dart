import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'screens/main_screen.dart';
import 'package:provider/provider.dart';
import 'providers/favorite_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'providers/auth_provider.dart';



void main() async {
  // 1. 위젯 바인딩 초기화
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // 2. 깃허브 가이드 방식의 초기화
  await FlutterNaverMap().init(
    clientId: '8px8q0aopz', // 사용자님의 Client ID
    onAuthFailed: (ex) {
      // 상세 에러 분기 처리 (README 방식)
      switch (ex.runtimeType) {
        case NQuotaExceededException:
          print("********* [인증오류] 사용량 초과 (한도 확인 필요) *********");
          break;
        case NUnauthorizedClientException:
          print("********* [인증오류] 인증 실패 (패키지명: com.knu.knu7 확인) *********");
          break;
        case NClientUnspecifiedException:
          print("********* [인증오류] 클라이언트 ID 미지정 *********");
          break;
        case NAnotherAuthFailedException:
          print("********* [인증오류] 기타 인증 실패: $ex *********");
          break;
        default:
          print("********* [인증오류] 알 수 없는 에러: $ex *********");
      }
    },
  );



  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FavoriteProvider()),
        // 3. AuthProvider 등록
        ChangeNotifierProvider(create: (_) => AuthProvider()),
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
        // 경북대 느낌이 물씬 나는 레드 컬러 테마!
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFDD1829)),
      ),
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}