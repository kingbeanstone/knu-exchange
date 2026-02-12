import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;

  User? get user => _user;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _authService.user.listen((User? newUser) {
      _user = newUser;
      notifyListeners();
    });
  }

  Future<void> signUp(String email, String password) async {
    final credential = await _authService.signUp(email, password);
    final user = credential.user;

    if (user == null) {
      throw FirebaseAuthException(
        code: 'user-null',
        message: '회원가입에 실패했어.',
      );
    }

    // 인증메일 발송
    await user.sendEmailVerification();

    // 인증 전에는 로그인 상태로 두지 않게(추천 UX)
    await _authService.signOut();
  }

  Future<void> login(String email, String password) async {
    final credential = await _authService.signIn(email, password);
    final user = credential.user;

    if (user == null) {
      throw FirebaseAuthException(
        code: 'user-null',
        message: '로그인에 실패했어.',
      );
    }

    // 최신 인증상태 반영
    await user.reload();
    final refreshed = FirebaseAuth.instance.currentUser;

    if (refreshed != null && !refreshed.emailVerified) {
      await _authService.signOut();
      throw FirebaseAuthException(
        code: 'email-not-verified',
        message: '이메일 인증을 먼저 완료해줘.',
      );
    }
  }

  Future<void> logout() => _authService.signOut();
}
