import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _appId = 'knu-exchange-app';

  // 로그인 상태 스트림
  Stream<User?> get user => _auth.authStateChanges();

  // 이메일/비밀번호 회원가입 및 프로필 생성
  Future<UserCredential> signUp(String email, String password, {required String nickname}) async {
    // 1. Firebase Auth 계정 생성
    final UserCredential credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final User? user = credential.user;

    if (user != null) {
      // 2. Firestore에 사용자 프로필 정보 저장
      // 경로 규칙 준수: /artifacts/{appId}/users/{userId}/{collectionName}
      await _db
          .collection('artifacts')
          .doc(_appId)
          .collection('users')
          .doc(user.uid)
          .collection('profile')
          .doc('info')
          .set({
        'uid': user.uid,
        'email': email,
        'displayName': nickname,
        'createdAt': FieldValue.serverTimestamp(),
        // 필요 시 교환학생 여부 등 추가 필드 확장 가능
      });

      // 3. Firebase Auth의 displayName도 업데이트 (선택 사항)
      await user.updateDisplayName(nickname);
    }

    return credential;
  }

  // 이메일/비밀번호 로그인
  Future<UserCredential> signIn(String email, String password) {
    return _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // 로그아웃
  Future<void> signOut() => _auth.signOut();
}