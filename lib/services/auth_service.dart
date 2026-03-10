import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../services/report_service.dart'; // [추가] 신고 서비스 연동

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final String _currentAppId = 'knu-exchange-app';
  final ReportService _reportService = ReportService(); // [추가]

  Stream<User?> get user => _auth.authStateChanges();

  // [추가] 특정 사용자의 Firestore 상세 프로필(isAdmin 포함) 정보를 가져옵니다.
  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    try {
      final doc = await _db
          .collection('artifacts')
          .doc(_currentAppId)
          .collection('users')
          .doc(uid)
          .collection('profile')
          .doc('info')
          .get();
      return doc.data();
    } catch (e) {
      debugPrint("사용자 프로필 로드 에러: $e");
      return null;
    }
  }

  // 사용자 Firestore 프로필 생성 및 업데이트 공통 로직
  Future<void> _updateUserProfile(User user, {String? nickname}) async {
    final userDoc = _db
        .collection('artifacts')
        .doc(_currentAppId)
        .collection('users')
        .doc(user.uid)
        .collection('profile')
        .doc('info');

    final docSnapshot = await userDoc.get();

    if (!docSnapshot.exists) {
      await userDoc.set({
        'uid': user.uid,
        'email': user.email,
        'displayName': nickname ?? user.displayName ?? user.email?.split('@')[0] ?? 'User',
        'photoUrl': user.photoURL,
        'createdAt': FieldValue.serverTimestamp(),
        'isExchangeStudent': false,
        'isAdmin': false,
        'loginType': 'password',
        'blockedUsers': [], // [추가] 차단 목록 초기화
      });

      if (nickname != null) {
        await user.updateDisplayName(nickname);
      }
    }
  }

  Future<UserCredential> signUp(String email, String password, {required String nickname}) async {
    final UserCredential credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (credential.user != null) {
      await _updateUserProfile(credential.user!, nickname: nickname);
    }
    return credential;
  }

  Future<UserCredential> signIn(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password
    );
    if (credential.user != null) {
      await _updateUserProfile(credential.user!);
    }
    return credential;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> updateNickname(String newNickname) async {
    final User? user = _auth.currentUser;
    if (user == null) return;
    await user.updateDisplayName(newNickname);
    await _db.collection('artifacts').doc(_currentAppId).collection('users').doc(user.uid).collection('profile').doc('info').update({'displayName': newNickname});
    await user.reload();
  }

  Future<void> deleteAccount() async {
    final User? user = _auth.currentUser;
    if (user == null) return;
    await _db.collection('artifacts').doc(_currentAppId).collection('users').doc(user.uid).collection('profile').doc('info').delete();
    await user.delete();
  }
  // [추가] 유저 차단 로직 (애플 가이드라인 준수)
  Future<void> blockUser(String targetUserId, String targetDisplayName) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    final userDoc = _db
        .collection('artifacts')
        .doc(_currentAppId)
        .collection('users')
        .doc(currentUser.uid)
        .collection('profile')
        .doc('info');

    try {
      // [수정] update 대신 set(merge: true)를 사용하여 문서가 없어도 생성되게 함
      await userDoc.set({
        'blockedUsers': FieldValue.arrayUnion([targetUserId])
      }, SetOptions(merge: true));

      // [확인] 개발자 알림용 신고 데이터 생성
      await _reportService.submitRawReport({
        'reporterId': currentUser.uid,
        'targetId': targetUserId,
        'targetName': targetDisplayName,
        'reason': 'User Blocked (Apple Policy)',
        'contentType': 'user',
        'createdAt': FieldValue.serverTimestamp(),
      });

      debugPrint("차단 및 신고 성공: $targetUserId");
    } catch (e) {
      debugPrint("차단 실패 에러: $e"); // 콘솔에서 에러 내용을 꼭 확인하세요!
    }
  }
}