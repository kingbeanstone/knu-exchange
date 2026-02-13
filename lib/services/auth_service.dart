import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// 전역 변수에서 appId와 config를 가져오는 로직 (Canvas 환경 대응)
final String _appId = 'default-app-id'; // 실제 환경에서는 __app_id 등을 사용하도록 구성 가능

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

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

    // Rule 3: Firestore 작업 전 사용자 인증 확인
    if (user != null) {
      try {
        // Rule 1: 지정된 경로 사용 (/artifacts/{appId}/users/{userId}/{collectionName})
        // 'knu-exchange-app'은 예시이며 환경에 맞는 appId를 사용하는 것이 중요합니다.
        const String currentAppId = 'knu-exchange-app';

        await _db
            .collection('artifacts')
            .doc(currentAppId)
            .collection('users')
            .doc(user.uid)
            .collection('profile')
            .doc('info')
            .set({
          'uid': user.uid,
          'email': email,
          'displayName': nickname,
          'createdAt': FieldValue.serverTimestamp(),
          'isExchangeStudent': false, // 기본값
        }).timeout(const Duration(seconds: 10)); // 타임아웃 추가 (무한 로딩 방지)

        // 3. 닉네임 업데이트
        await user.updateDisplayName(nickname);
      } catch (e) {
        // Firestore 저장 실패 시 로그 (디버깅용)
        print("Firestore profile creation failed: $e");
        // 프로필 저장은 실패해도 계정은 생성되었으므로 진행하거나,
        // 필요에 따라 계정 삭제 로직을 추가할 수 있습니다.
      }
    }

    return credential;
  }

  Future<UserCredential> signIn(String email, String password) {
    return _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() => _auth.signOut();
}