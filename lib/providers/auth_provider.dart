import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;

  User? get user => _user;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    // 앱 시작 시 로그인 상태 변경 감시
    _authService.user.listen((User? newUser) {
      _user = newUser;
      notifyListeners();
    });
  }

  Future<void> login(String email, String password) async {
    await _authService.signIn(email, password);
  }

  Future<void> logout() async {
    await _authService.signOut();
  }
}