import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _currentAppId = 'knu-exchange-app';

  Stream<User?> get user => _auth.authStateChanges();

  // 회원가입
  Future<UserCredential> signUp(String email, String password, {required String nickname}) async {
    final UserCredential credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final User? user = credential.user;

    if (user != null) {
      await _db
          .collection('artifacts')
          .doc(_currentAppId)
          .collection('users')
          .doc(user.uid)
          .collection('profile')
          .doc('info')
          .set({
        'uid': user.uid,
        'email': email,
        'displayName': nickname,
        'createdAt': FieldValue.serverTimestamp(),
        'isExchangeStudent': false,
      });

      await user.updateDisplayName(nickname);
    }

    return credential;
  }

  // 닉네임 수정
  Future<void> updateNickname(String newNickname) async {
    final User? user = _auth.currentUser;
    if (user == null) return;

    await user.updateDisplayName(newNickname);

    await _db
        .collection('artifacts')
        .doc(_currentAppId)
        .collection('users')
        .doc(user.uid)
        .collection('profile')
        .doc('info')
        .update({
      'displayName': newNickname,
    });

    await user.reload();
  }

  // [추가] 계정 삭제 로직
  Future<void> deleteAccount() async {
    final User? user = _auth.currentUser;
    if (user == null) return;

    final String uid = user.uid;

    try {
      // 1. Firestore의 사용자 관련 데이터 삭제 (프로필 정보)
      // 즐겨찾기는 삭제하지 않기로 했으므로 프로필 정보만 삭제합니다.
      await _db
          .collection('artifacts')
          .doc(_currentAppId)
          .collection('users')
          .doc(uid)
          .collection('profile')
          .doc('info')
          .delete();

      // 2. Firebase Auth에서 사용자 삭제
      // 주의: 로그인한 지 오래된 경우 'requires-recent-login' 에러가 발생할 수 있음
      await user.delete();
    } catch (e) {
      rethrow;
    }
  }

  Future<UserCredential> signIn(String email, String password) {
    return _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() => _auth.signOut();
}