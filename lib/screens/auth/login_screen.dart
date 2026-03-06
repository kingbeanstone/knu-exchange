import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import '../../providers/auth_provider.dart';
import '../../utils/app_colors.dart';
import '../../widgets/auth/auth_header.dart';
import '../../widgets/auth/login_form.dart';
import '../settings/signup_screen.dart';

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

      // 2. [수정] 성공 시 명시적으로 스낵바를 띄우고 화면을 닫습니다.
      // SettingsScreen은 Provider를 구독하고 있으므로 pop 이후 즉시 프로필 화면으로 바뀝니다.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login successful! Welcome.'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 1),
        ),
      );

      // 약간의 지연 후 창을 닫아 스낵바를 확인할 시간을 줍니다.
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted && Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      });

    } on FirebaseAuthException catch (e) {
      if (mounted) {
        String errorMessage = 'Login failed.';
        if (e.code == 'user-not-found') errorMessage = 'No user found with this email.';
        else if (e.code == 'wrong-password') errorMessage = 'Incorrect password.';
        else if (e.code == 'invalid-email') errorMessage = 'Invalid email format.';
        else if (e.code == 'email-not-verified') errorMessage = 'Please verify your email first.';

        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage), backgroundColor: Colors.red)
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('An error occurred: $e'), backgroundColor: Colors.red)
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // isLoading 상태를 감시하여 버튼 활성/비활성 처리
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