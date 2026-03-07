import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;
  bool _isAdmin = false;
  bool _isLoading = false;
  bool _isInitialLoading = true;
  bool _isNotificationsEnabled = true;

  User? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isAdmin => _isAdmin;
  bool get isLoading => _isLoading;
  bool get isInitialLoading => _isInitialLoading;
  bool get isNotificationsEnabled => _isNotificationsEnabled;

  AuthProvider() {
    _initializeAuth();
  }

  void _initializeAuth() {
    // 1. 현재 사용자 즉시 할당
    _user = FirebaseAuth.instance.currentUser;
    if (_user != null) {
      _fetchUserData(_user!.uid);
    }

    // 2. 인증 상태 변화 스트림 리스너
    _authService.user.listen((User? newUser) async {
      _user = newUser;

      if (_user != null) {
        await _fetchUserData(_user!.uid);
      } else {
        _isAdmin = false;
        _isNotificationsEnabled = true; // 로그아웃 시 초기화
      }

      _isInitialLoading = false;
      notifyListeners(); // 상태 변화 알림 -> UI 토글 유도
    });
  }

  /// Firestore에서 관리자 여부 및 알림 설정을 확인합니다.
  Future<void> _fetchUserData(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('artifacts')
          .doc('knu-exchange-app')
          .collection('users')
          .doc(uid)
          .collection('profile')
          .doc('info')
          .get();

      if (doc.exists) {
        final data = doc.data();
        _isAdmin = data?['isAdmin'] ?? false;
        _isNotificationsEnabled = data?['isNotificationsEnabled'] ?? true;
      }
    } catch (e) {
      debugPrint("Error fetching user data: $e");
    }
    notifyListeners(); // 데이터 로드 완료 후 알림
  }

  /// 알림 설정 토글 및 Firestore 업데이트
  Future<void> toggleNotifications(bool value) async {
    if (_user == null) return;

    _isNotificationsEnabled = value;
    notifyListeners();

    try {
      await FirebaseFirestore.instance
          .collection('artifacts')
          .doc('knu-exchange-app')
          .collection('users')
          .doc(_user!.uid)
          .collection('profile')
          .doc('info')
          .set({
        'isNotificationsEnabled': value,
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint("Error updating notification setting: $e");
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// 로그인 로직: 데이터 로딩 완료를 보장하여 UI 토글이 즉시 반영되도록 합니다.
  Future<void> login(String email, String password) async {
    _setLoading(true);
    try {
      final credential = await _authService.signIn(email, password);
      if (credential.user != null) {
        // 이메일 인증 여부 확인
        if (!credential.user!.emailVerified) {
          await credential.user!.reload();
          if (!FirebaseAuth.instance.currentUser!.emailVerified) {
            throw FirebaseAuthException(code: 'email-not-verified');
          }
        }
        // 사용자 데이터 강제 최신화 (isAdmin, 알림 설정 등)
        await _fetchUserData(credential.user!.uid);
      }
    } finally {
      _setLoading(false);
    }
  }

  /// 회원가입 로직
  Future<void> signUp(String email, String password, {required String nickname}) async {
    _setLoading(true);
    try {
      final credential = await _authService.signUp(email, password, nickname: nickname);
      if (credential.user != null) {
        await credential.user!.sendEmailVerification();
        await _authService.signOut();
      }
    } finally {
      _setLoading(false);
    }
  }

  /// 로그아웃 로직
  Future<void> logout() async {
    _setLoading(true);
    try {
      await _authService.signOut();
      _user = null;
      _isAdmin = false;
    } finally {
      _setLoading(false);
    }
  }

  /// 닉네임 변경 로직
  Future<void> updateNickname(String newNickname) async {
    _setLoading(true);
    try {
      await _authService.updateNickname(newNickname);
      _user = FirebaseAuth.instance.currentUser;
      // 변경 사항 반영을 위해 데이터 다시 로드
      if (_user != null) await _fetchUserData(_user!.uid);
    } finally {
      _setLoading(false);
    }
  }

  /// 계정 삭제 로직
  Future<void> deleteAccount() async {
    _setLoading(true);
    try {
      await _authService.deleteAccount();
      _user = null;
      _isAdmin = false;
    } finally {
      _setLoading(false);
    }
  }
}