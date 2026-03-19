import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';

class LinkUtil {
  /// URL을 외부 브라우저에서 안전하게 엽니다.
  /// 프로토콜(http/https)이 없는 경우 자동으로 https://를 추가합니다.
  static Future<void> launch(String url) async {
    if (url.isEmpty) return;

    // 1. 프로토콜이 없는 경우 처리
    String processedUrl = url.trim();
    if (!processedUrl.startsWith('http://') && !processedUrl.startsWith('https://')) {
      processedUrl = 'https://$processedUrl';
    }

    final Uri uri = Uri.parse(processedUrl);

    try {
      // 2. 실행 가능 여부 확인
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        debugPrint("Could not launch $processedUrl");
      }
    } catch (e) {
      debugPrint("Error launching URL: $e");
    }
  }
}