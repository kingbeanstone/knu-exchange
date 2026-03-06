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

    // 로딩 상태 시작 전에 포커스 해제
    FocusScope.of(context).unfocus();

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      await authProvider.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      // [수정] 로그인 성공 시 안전하게 Navigator를 닫습니다.
      // 비동기 작업(await) 이후에는 context가 여전히 유효한지 확인하는 것이 필수입니다.
      if (!mounted) return;

      // 만약 Navigator 스택에 현재 화면이 존재한다면 닫습니다.
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      // 성공 피드백 (선택 사항)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Welcome back!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        String errorMessage = 'Login failed.';
        if (e.code == 'user-not-found') errorMessage = 'No user found with this email.';
        else if (e.code == 'wrong-password') errorMessage = 'Incorrect password.';
        else if (e.code == 'invalid-email') errorMessage = 'Invalid email format.';

        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.message ?? errorMessage))
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('An unexpected error occurred: $e'))
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        // 뒤로가기 버튼은 자동으로 유지됨
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
                isLoading: authProvider.isLoading,
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