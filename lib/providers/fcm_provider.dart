import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../services/fcm_service.dart';
import '../services/community_service.dart';

class FCMProvider with ChangeNotifier {
  final FCMService _fcmService = FCMService();
  final CommunityService _communityService = CommunityService();

  String? _token;
  String? get token => _token;

  /// FCM 초기화 및 토픽 구독 프로세스
  Future<void> setupFCM(String userId) async {
    try {
      // 1. FCM 서비스 초기화 (권한 요청 등)
      await _fcmService.initialize();

      // 2. iOS의 경우 APNs 토큰 준비 대기
      if (Platform.isIOS) {
        String? apnsToken = await FirebaseMessaging.instance.getAPNSToken();
        if (apnsToken == null) {
          debugPrint("FCM: Waiting for APNs token...");
          await Future.delayed(const Duration(seconds: 2));
        }
      }

      // 3. 기기 토큰 획득 및 서버 저장 (개별 알림용)
      _token = await _fcmService.getToken();
      if (_token != null) {
        await _communityService.updateFcmToken(userId, _token!);

        // 4. [핵심] 공지사항 토픽 구독
        // 방식 B의 핵심으로, 모든 기기가 'notices' 토픽을 구독하게 합니다.
        await _fcmService.subscribeToTopic('notices');
        debugPrint("FCM: Topic 'notices' subscribed for $userId");

        // 5. 토큰 갱신 리스너
        FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
          _token = newToken;
          await _communityService.updateFcmToken(userId, newToken);
          notifyListeners();
        });
      }
    } catch (e) {
      debugPrint("FCM Provider Error: $e");
    }
    notifyListeners();
  }
}