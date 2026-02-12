import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import '../../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoginMode = true; // true: 로그인, false: 회원가입
  bool _isLoading = false;

  final Color knuRed = const Color(0xFFDD1829);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      if (_isLoginMode) {
        await authProvider.login(email, password);
        if (mounted) Navigator.pop(context);
      } else {
        await authProvider.signUp(email, password);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('인증 메일을 보냈어! 메일 인증 후 로그인해줘.')),
          );
        }
        setState(() => _isLoginMode = true);
      }
    } on FirebaseAuthException catch (e) {
      final msg = switch (e.code) {
        'email-already-in-use' => '이미 사용 중인 이메일이야.',
        'invalid-email' => '이메일 형식이 올바르지 않아.',
        'weak-password' => '비밀번호가 너무 약해. (6자 이상)',
        'user-not-found' => '해당 이메일의 사용자가 없어.',
        'wrong-password' => '비밀번호가 틀렸어.',
        'email-not-verified' => '이메일 인증을 먼저 완료해줘.',
        'network-request-failed' => '네트워크 연결을 확인해줘.',
        'user-null' => '인증 처리 중 문제가 생겼어.',
        _ => '인증 오류: ${e.message ?? e.code}',
      };

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isLoginMode ? 'Login' : 'Sign Up'),
        backgroundColor: knuRed,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.school, size: 80, color: knuRed),
                const SizedBox(height: 10),
                Text(
                  'KNU Exchange',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: knuRed,
                  ),
                ),
                const SizedBox(height: 30),

                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email (ID)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (val) {
                    final v = (val ?? '').trim();
                    if (v.isEmpty) return 'Enter email';
                    if (!v.contains('@')) return 'Enter a valid email';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                  validator: (val) {
                    final v = (val ?? '').trim();
                    if (v.isEmpty) return 'Enter password';
                    if (v.length < 6) return 'Password too short';
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: knuRed,
                      foregroundColor: Colors.white,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(_isLoginMode ? 'Login' : 'Sign Up'),
                  ),
                ),

                TextButton(
                  onPressed: _isLoading
                      ? null
                      : () => setState(() => _isLoginMode = !_isLoginMode),
                  child: Text(
                    _isLoginMode
                        ? "Don't have an account? Sign Up"
                        : "Already have an account? Login",
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
