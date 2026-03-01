import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../services/fcm_service.dart';
import '../services/community_service.dart';

class FCMProvider with ChangeNotifier {
  final FCMService _fcmService = FCMService();
  final CommunityService _communityService = CommunityService();

  String? _token;
  String? get token => _token;

  /// FCM 초기화 및 토큰 획득 프로세스
  Future<void> setupFCM(String userId) async {
    try {
      // 1. 서비스 초기화 (권한 요청 및 기본 핸들러 설정)
      await _fcmService.initialize();

      // 2. 현재 기기의 토큰 가져오기
      _token = await _fcmService.getToken();

      if (_token != null) {
        // 3. 개인별 알림을 위한 토큰 서버(Firestore) 등록
        await _communityService.updateFcmToken(userId, _token!);

        // 4. 전체 공지사항 알림을 위한 'notices' 토픽 구독
        await _fcmService.subscribeToTopic('notices');

        // 5. [중요] 토큰 갱신 리스너 등록
        // 앱 실행 중 토큰이 변경되어도 서버 데이터를 즉시 최신화합니다.
        FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
          _token = newToken;
          await _communityService.updateFcmToken(userId, newToken);
          notifyListeners();
        });

        debugPrint("FCM Setup complete for user: $userId");
      }
    } catch (e) {
      debugPrint("FCM Setup Error: $e");
    }
    notifyListeners();
  }

  /// 디버깅을 위해 현재 토큰을 클립보드에 복사
  void copyTokenToClipboard(BuildContext context) {
    if (_token != null) {
      Clipboard.setData(ClipboardData(text: _token!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('FCM Token copied to clipboard!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Token is not available yet.')),
      );
    }
  }
}