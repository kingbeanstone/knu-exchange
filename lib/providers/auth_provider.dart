import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;
  bool _isAdmin = false; // [추가] 관리자 상태 변수
  bool _isLoading = false;

  User? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isAdmin => _isAdmin; // [추가] 관리자 여부 Getter
  bool get isLoading => _isLoading;

  AuthProvider() {
    _user = FirebaseAuth.instance.currentUser;
    if (_user != null) _checkAdminStatus(_user!.uid);

    _authService.user.listen((User? newUser) {
      _user = newUser;
      if (newUser != null) {
        _checkAdminStatus(newUser.uid);
      } else {
        _isAdmin = false;
        notifyListeners();
      }
    });
  }

  // [추가] 사용자의 관리자 권한 정보를 확인합니다.
  Future<void> _checkAdminStatus(String uid) async {
    final profile = await _authService.getUserProfile(uid);
    _isAdmin = profile?['isAdmin'] ?? false;
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
        await _checkAdminStatus(credential.user!.uid); // 로그인 즉시 관리자 체크

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