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

  Future<void> signUp(String email, String password, {required String nickname}) async {
    try {
      final credential = await _authService.signUp(
        email,
        password,
        nickname: nickname,
      ).timeout(const Duration(seconds: 15)); // 전체 프로세스 타임아웃

      final user = credential.user;

      if (user != null) {
        // 인증메일 발송
        await user.sendEmailVerification();
        // 인증 전에는 세션을 유지하지 않도록 로그아웃
        await _authService.signOut();
      }
    } catch (e) {
      // 에러 발생 시 상위(Screen)로 전달
      rethrow;
    }
  }

  Future<void> login(String email, String password) async {
    final credential = await _authService.signIn(email, password);
    final user = credential.user;

    if (user != null) {
      await user.reload();
      final refreshedUser = FirebaseAuth.instance.currentUser;

      if (refreshedUser != null && !refreshedUser.emailVerified) {
        await _authService.signOut();
        throw FirebaseAuthException(
          code: 'email-not-verified',
          message: 'Please verify your email first.',
        );
      }
    }
  }

  Future<void> logout() => _authService.signOut();
}