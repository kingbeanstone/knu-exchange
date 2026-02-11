import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 로그인 상태 스트림
  Stream<User?> get user => _auth.authStateChanges();

  // 이메일/비밀번호 회원가입
  Future<UserCredential?> signUp(String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(email: email, password: password);
  }

  // 이메일/비밀번호 로그인
  Future<UserCredential?> signIn(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  // 로그아웃
  Future<void> signOut() async {
    await _auth.signOut();
  }
}