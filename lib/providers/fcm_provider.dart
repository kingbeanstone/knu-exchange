import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/fcm_service.dart';
import '../services/community_service.dart';

class FCMProvider with ChangeNotifier {
  final FCMService _fcmService = FCMService();
  final CommunityService _communityService = CommunityService();

  String? _token;
  String? get token => _token;

  // FCM 초기화 및 토큰 획득
  Future<void> setupFCM(String userId) async {
    try {
      await _fcmService.initialize();
      _token = await _fcmService.getToken();

      if (_token != null) {
        // 서버에 저장 시도
        await _communityService.updateFcmToken(userId, _token!);
        debugPrint("FCM Token saved to Firestore: $_token");
      } else {
        debugPrint("FCM Token is null");
      }
    } catch (e) {
      debugPrint("FCM Setup Error: $e");
    }
    notifyListeners();
  }

  // 토큰을 클립보드에 복사하고 토스트(SnackBar) 메시지 표시
  void copyTokenToClipboard(BuildContext context) {
    if (_token != null) {
      Clipboard.setData(ClipboardData(text: _token!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('FCM Token copied to clipboard!'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No token found. Please check setup.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}