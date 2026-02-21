import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final String _currentAppId = 'knu-exchange-app';

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
        'isAdmin': false, // 초기 가입 시에는 항상 일반 유저
        'loginType': 'password',
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
}