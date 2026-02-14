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

  // [추가] 닉네임 수정 로직
  Future<void> updateNickname(String newNickname) async {
    final User? user = _auth.currentUser;
    if (user == null) return;

    // 1. Firebase Auth의 displayName 업데이트
    await user.updateDisplayName(newNickname);

    // 2. Firestore의 프로필 정보 업데이트
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

    // Auth 상태 변경을 강제로 알리기 위해 reload
    await user.reload();
  }

  Future<UserCredential> signIn(String email, String password) {
    return _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() => _auth.signOut();
}