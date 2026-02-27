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

  // [추가] 알림 활성화 상태
  bool _isNotificationsEnabled = true;

  User? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isAdmin => _isAdmin;
  bool get isLoading => _isLoading;
  bool get isInitialLoading => _isInitialLoading;
  bool get isNotificationsEnabled => _isNotificationsEnabled; // [추가] 게터

  AuthProvider() {
    _initializeAuth();
  }

  void _initializeAuth() {
    _user = FirebaseAuth.instance.currentUser;
    if (_user != null) {
      _fetchUserData(_user!.uid);
    }

    _authService.user.listen((User? newUser) async {
      _user = newUser;

      if (_user != null) {
        await _fetchUserData(_user!.uid);
      } else {
        _isAdmin = false;
        _isNotificationsEnabled = true; // 로그아웃 시 초기화
      }

      _isInitialLoading = false;
      notifyListeners();
    });
  }

  // [수정] Firestore에서 관리자 여부 및 알림 설정을 확인합니다.
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
        _isNotificationsEnabled = data?['isNotificationsEnabled'] ?? true; // 기본값 true
      }
    } catch (e) {
      debugPrint("Error fetching user data: $e");
    }

    notifyListeners();
  }

  // [추가] 알림 설정 토글 및 Firestore 업데이트
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

  Future<void> login(String email, String password) async {
    _setLoading(true);
    try {
      final credential = await _authService.signIn(email, password);
      if (credential.user != null) {
        await credential.user!.reload();
        await _fetchUserData(credential.user!.uid);

        final refreshedUser = FirebaseAuth.instance.currentUser;
        if (refreshedUser != null && !refreshedUser.emailVerified) {
          throw FirebaseAuthException(code: 'email-not-verified');
        }
      }
    } finally {
      _setLoading(false);
    }
  }

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

  Future<void> logout() async {
    _setLoading(true);
    try {
      await _authService.signOut();
      _isAdmin = false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateNickname(String newNickname) async {
    _setLoading(true);
    try {
      await _authService.updateNickname(newNickname);
      _user = FirebaseAuth.instance.currentUser;
    } finally {
      _setLoading(false);
    }
  }

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