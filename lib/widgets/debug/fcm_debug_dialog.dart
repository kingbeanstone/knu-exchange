import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class FcmProvider extends ChangeNotifier {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _token;
  String? get token => _token;

  /// 🔥 토큰 초기화 (로그인 시 호출)
  Future<void> initialize(String appId, String userId) async {
    _token = await _messaging.getToken();

    if (_token == null) return;

    await _firestore
        .collection('artifacts')
        .doc(appId)
        .collection('users')
        .doc(userId)
        .collection('tokens')
        .doc(_token)
        .set({
      'token': _token,
      'createdAt': FieldValue.serverTimestamp(),
    });

    notifyListeners();
  }

  /// 🔥 로그아웃 시 토큰 삭제
  Future<void> logout(String appId, String userId) async {
    if (_token == null) return;

    await _firestore
        .collection('artifacts')
        .doc(appId)
        .collection('users')
        .doc(userId)
        .collection('tokens')
        .doc(_token)
        .delete();
  }

  /// 🔥 디버그용 클립보드 복사
  Future<void> copyTokenToClipboard() async {
    if (_token == null) return;
    await Clipboard.setData(ClipboardData(text: _token!));
  }
}