import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart'; // [확인] UserModel 임포트

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;
  UserModel? _userModel; // 커스텀 UserModel 저장 변수
  bool _isAdmin = false;
  bool _isLoading = false;
  bool _isInitialLoading = true;
  bool _isNotificationsEnabled = true;

  User? get user => _user;
  // 외부(CommunityScreen 등)에서 차단 목록을 참조하기 위한 게터
  UserModel? get userModel => _userModel;

  bool get isAuthenticated => _user != null && _user!.emailVerified;
  bool get isAdmin => _isAdmin;
  bool get isLoading => _isLoading;
  bool get isInitialLoading => _isInitialLoading;
  bool get isNotificationsEnabled => _isNotificationsEnabled;

  bool _isWaitingVerification = false;
  bool get isWaitingVerification => _isWaitingVerification;

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
        // 로그아웃 시 관련 상태 초기화
        _userModel = null;
        _isAdmin = false;
        _isNotificationsEnabled = true;
      }

      _isInitialLoading = false;
      notifyListeners();
    });
  }

  /// [핵심 수정] Firestore에서 유저 데이터를 가져와 UserModel을 완성합니다.
  Future<void> _fetchUserData(String uid) async {
    try {
      // 1. AuthService를 통해 Firestore의 profile/info 데이터를 가져옵니다.
      final data = await _authService.getUserProfile(uid);

      if (data != null) {
        // 2. 가져온 Map 데이터를 UserModel 객체로 변환하여 저장합니다.
        // 여기에 blockedUsers 정보가 포함되어 있어야 새로고침 시 필터링이 작동합니다.
        _userModel = UserModel.fromMap(data);

        // 3. 기타 UI용 상태 값 업데이트
        _isAdmin = _userModel?.isAdmin ?? false;
        _isNotificationsEnabled = data['isNotificationsEnabled'] ?? true;
      }
    } catch (e) {
      debugPrint("Error fetching user data: $e");
    }
    notifyListeners();
  }

  /// 차단 기능 실행 후 최신 차단 목록을 반영하기 위해 데이터를 다시 불러오는 메서드
  Future<void> refreshUserModel() async {
    if (_user != null) {
      await _fetchUserData(_user!.uid); // Firestore에서 최신 blockedUsers 가져옴
      debugPrint("📢 내 프로필 동기화 완료: ${_userModel?.blockedUsers.length}명 차단 중");
    }
  }

  // 알림 설정 토글
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

  /// 로그인 로직
  Future<void> login(String email, String password) async {
    _setLoading(true);
    try {
      final credential = await _authService.signIn(email, password);
      User? user = credential.user;

      if (user != null) {
        await user.reload();
        user = FirebaseAuth.instance.currentUser;

        if (user != null && !user.emailVerified) {
          // 인증되지 않았더라도 일단 _user에 저장하여 재발송 버튼이 작동할 수 있게 합니다.
          _user = user;
          throw FirebaseAuthException(code: 'email-not-verified');
        }

        _user = user;
        await _fetchUserData(user!.uid);
      }
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }


  /// 이메일 인증 확인 메서드
  Future<bool> checkEmailVerified() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.reload();
      if (user.emailVerified) {
        _user = user;
        _isWaitingVerification = false;
        await _fetchUserData(user.uid); // 인증 완료 시 데이터 로드
        notifyListeners();
        return true;
      }
    }
    return false;
  }

  Future<void> resendVerificationEmail() async {
    _setLoading(true);
    try {
      await _authService.sendVerificationEmail();
      _isWaitingVerification = true;
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  int _resendCooldown = 0;
  int get resendCooldown => _resendCooldown;
  Timer? _timer;

  Future<void> resendVerificationEmailWithCooldown() async {
    if (_resendCooldown > 0) return; // 쿨다운 중이면 실행 안 함

    try {
      await resendVerificationEmail(); // 기존 재전송 함수 호출

      // 60초 타이머 시작
      _resendCooldown = 60;
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_resendCooldown == 0) {
          timer.cancel();
        } else {
          _resendCooldown--;
          notifyListeners();
        }
      });
    } catch (e) {
      rethrow;
    }
  }

  /// 로그아웃 로직
  Future<void> logout() async {
    _setLoading(true);
    try {
      await _authService.signOut();
      _user = null;
      _userModel = null; // 유저 모델 초기화
      _isAdmin = false;
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  /// 닉네임 변경 로직
  Future<void> updateNickname(String newNickname) async {
    _setLoading(true);
    try {
      await _authService.updateNickname(newNickname);
      _user = FirebaseAuth.instance.currentUser;
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
      _userModel = null;
      _isAdmin = false;
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  /// 회원가입 로직 (최종 개선 버전)
  Future<void> signUp(String email, String password, {required String nickname}) async {
    _setLoading(true);
    try {
      // 1. 서비스 호출하여 유저 생성 및 Firestore 프로필 저장
      final credential = await _authService.signUp(email, password, nickname: nickname);

      if (credential.user != null) {
        // 2. 인증 이메일 발송
        await credential.user!.sendEmailVerification();

        _isWaitingVerification = true;
        notifyListeners();
      }
    } catch (e) {
      // 에러 발생 시 로그를 남기고 UI(Screen)로 에러를 던짐
      debugPrint("❌ 회원가입/메일발송 에러: $e");
      rethrow;
    } finally {
      _setLoading(false);
    }
  }
}