import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;

  User? get user => _user;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _user = FirebaseAuth.instance.currentUser;
    _authService.user.listen((User? newUser) {
      _user = newUser;
      notifyListeners();
    });
  }

  // [추가] 프로필 수정 호출 메서드
  Future<void> updateNickname(String newNickname) async {
    try {
      await _authService.updateNickname(newNickname);
      // 최신 사용자 정보로 로컬 상태 갱신
      _user = FirebaseAuth.instance.currentUser;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signUp(String email, String password, {required String nickname}) async {
    try {
      final credential = await _authService.signUp(email, password, nickname: nickname);
      if (credential.user != null) {
        await credential.user!.sendEmailVerification();
        await _authService.signOut();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> login(String email, String password) async {
    final credential = await _authService.signIn(email, password);
    if (credential.user != null) {
      await credential.user!.reload();
      final refreshedUser = FirebaseAuth.instance.currentUser;
      if (refreshedUser != null && !refreshedUser.emailVerified) {
        await _authService.signOut();
        throw FirebaseAuthException(code: 'email-not-verified', message: 'Please verify your email first.');
      }
    }
  }

  Future<void> logout() => _authService.signOut();
}