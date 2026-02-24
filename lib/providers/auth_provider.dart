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
  bool _isInitialLoading = true; // [추가] 초기 인증 확인 상태

  User? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isAdmin => _isAdmin;
  bool get isLoading => _isLoading;
  bool get isInitialLoading => _isInitialLoading; // [추가] 게터

  AuthProvider() {
    _initializeAuth();
  }

  // [수정] 초기 로그인 상태를 확인하고 스트림을 구독합니다.
  void _initializeAuth() {
    _user = FirebaseAuth.instance.currentUser;
    if (_user != null) {
      _checkAdminStatus(_user!.uid);
    }

    _authService.user.listen((User? newUser) async {
      _user = newUser;

      if (_user != null) {
        await _checkAdminStatus(_user!.uid);
      } else {
        _isAdmin = false;
      }

      // 초기 확인 완료 후 상태 변경
      _isInitialLoading = false;
      notifyListeners();
    });
  }

  // 🔥 Firestore에서 관리자 여부 확인
  Future<void> _checkAdminStatus(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('artifacts')
          .doc('knu-exchange-app')
          .collection('users')
          .doc(uid)
          .collection('profile')
          .doc('info')
          .get();

      _isAdmin = doc.data()?['isAdmin'] ?? false;
    } catch (e) {
      _isAdmin = false;
    }

    notifyListeners();
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
        await _checkAdminStatus(credential.user!.uid);

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