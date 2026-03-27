import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class FCMService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  /// FCM 초기 설정 및 권한 요청
  Future<void> initialize() async {
    // 1. 알림 권한 요청 (iOS/Android 13+)
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('FCM: User granted permission');
    }

    // 2. 포그라운드(앱 실행 중) 메시지 처리
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('FCM: Received message in foreground');
      if (message.notification != null) {
        // 포그라운드에서는 시스템 알림이 자동으로 뜨지 않으므로,
        // 필요한 경우 여기서 커스텀 스낵바나 로컬 알림을 띄울 수 있습니다.
        debugPrint('Notification: ${message.notification?.title}');
      }
    });

    // 3. 알림 클릭으로 앱을 연 경우 처리 (백그라운드 상태였을 때)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('FCM: App opened by notification click');
      // 여기서 message.data를 분석해 특정 화면(예: 공지사항 상세)으로 이동시킬 수 있습니다.
    });

    // 4. 앱이 완전히 종료된 상태에서 알림 클릭으로 시작된 경우 확인
    RemoteMessage? initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      debugPrint('FCM: App started from terminated state via notification');
    }
  }

  /// 특정 토픽(예: 'notices') 구독 로직
  /// 공지사항 등록 시 모든 사용자가 알림을 받도록 이 토픽을 구독합니다.
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      debugPrint('FCM: Subscribed to topic: $topic');
    } catch (e) {
      debugPrint('FCM: Error subscribing to topic: $e');
    }
  }

  /// 기기 고유 토큰 획득 (개별 알림용)
  Future<String?> getToken() async {
    try {
      // iOS의 경우 APNs 토큰이 먼저 활성화되어야 할 수도 있습니다.
      String? token = await _messaging.getToken();
      return token;
    } catch (e) {
      debugPrint("FCM: Error fetching token: $e");
      return null;
    }
  }
}