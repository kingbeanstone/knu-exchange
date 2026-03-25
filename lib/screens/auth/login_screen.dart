import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import '../../providers/auth_provider.dart';
import '../../utils/app_colors.dart';
import '../../widgets/auth/auth_header.dart';
import '../../widgets/auth/login_form.dart';
import '../../widgets/auth/verification_widgets.dart';
import '../settings/signup_screen.dart';
import 'email_verification_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// 로그인 버튼 클릭 시 실행되는 함수
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      // 1. 로그인 시도 및 사용자 데이터 로드 완료까지 대기
      await authProvider.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (!mounted) return;

      // 2. 성공 시 성공 메시지 표시 후 화면 닫기
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login successful! Welcome.'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 1),
        ),
      );

      // 약간의 지연 후 이전 화면으로 돌아감
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted && Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      });

    } on FirebaseAuthException catch (e) {
      if (mounted) {
        if (e.code == 'email-not-verified') {
          // [핵심] 이메일 미인증 시 재발송 다이얼로그 노출
          _showResendDialog(authProvider);
        } else {
          // 기타 에러 처리
          String errorMessage = 'Login failed.';
          if (e.code == 'user-not-found') errorMessage = 'No user found with this email.';
          else if (e.code == 'wrong-password') errorMessage = 'Incorrect password.';
          else if (e.code == 'invalid-email') errorMessage = 'Invalid email format.';

          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(errorMessage), backgroundColor: Colors.red)
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('An error occurred: $e'), backgroundColor: Colors.red)
        );
      }
    }
  }

  /// 미인증 사용자에게 재발송 권유 다이얼로그를 보여주는 함수
  void _showResendDialog(AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => ResendVerificationDialog(
        onResend: () async {
          // 1. 인증 메일 재발송 요청
          await authProvider.resendVerificationEmail();

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('New verification link sent! Please check your inbox.'),
                backgroundColor: Colors.blue,
              ),
            );

            // 2. 실시간 인증 대기 화면으로 이동
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EmailVerificationScreen()),
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // AuthProvider의 isLoading 상태를 감시하여 버튼 비활성화 처리
    final isLoading = context.select<AuthProvider, bool>((p) => p.isLoading);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const AuthHeader(),
              const SizedBox(height: 40),

              // 로그인 입력 폼 위젯 (email, password)
              LoginForm(
                formKey: _formKey,
                emailController: _emailController,
                passwordController: _passwordController,
                isLoading: isLoading,
                onSubmit: _submit,
              ),

              const SizedBox(height: 24),
              _buildSignUpLink(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  /// 회원가입 화면으로 이동하는 링크 버튼
  Widget _buildSignUpLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Don't have an account?"),
        TextButton(
          onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SignUpScreen())
          ),
          child: const Text(
              'Sign Up',
              style: TextStyle(color: AppColors.knuRed, fontWeight: FontWeight.bold)
          ),
        ),
      ],
    );
  }
}