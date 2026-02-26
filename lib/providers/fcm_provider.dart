import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/fcm_service.dart';
import '../services/community_service.dart';

class FCMProvider with ChangeNotifier {
  final FCMService _fcmService = FCMService();
  final CommunityService _communityService = CommunityService();

  String? _token;
  String? get token => _token;

  // FCM 초기화 및 토큰 획득 프로세스
  Future<void> setupFCM(String userId) async {
    try {
      await _fcmService.initialize();
      _token = await _fcmService.getToken();

      if (_token != null) {
        // 1. 개인별 알림을 위한 토큰 서버 등록
        await _communityService.updateFcmToken(userId, _token!);

        // 2. [추가] 전체 공지사항 알림을 위한 토픽 구독
        // 모든 사용자가 'notices' 토픽을 구독하게 하여 서버에서 한 번에 쏘게 합니다.
        await _fcmService.subscribeToTopic('notices');

        debugPrint("FCM Setup complete for user: $userId");
      }
    } catch (e) {
      debugPrint("FCM Setup Error: $e");
    }
    notifyListeners();
  }

  void copyTokenToClipboard(BuildContext context) {
    if (_token != null) {
      Clipboard.setData(ClipboardData(text: _token!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('FCM Token copied to clipboard!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}