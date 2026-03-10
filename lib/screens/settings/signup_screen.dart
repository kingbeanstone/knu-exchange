import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import '../auth/email_verification_screen.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_colors.dart';
import '../../widgets/auth/signup_form.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isEulaAgreed = false;

  @override
  void dispose() {
    _emailController.dispose();
    _nicknameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // [통합 수정] 약관 체크와 회원가입 로직을 하나로 합쳤습니다.
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // 1. 약관 동의 여부 먼저 확인
    if (!_isEulaAgreed) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You must agree to the Terms (EULA) to continue.'))
      );
      return;
    }

    // 2. 가입 진행
    FocusScope.of(context).unfocus();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      await authProvider.signUp(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        nickname: _nicknameController.text.trim(),
      );

      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const EmailVerificationScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        String msg = _getErrorMessage(e.code);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  String _getErrorMessage(String code) {
    switch (code) {
      case 'email-already-in-use': return 'This email is already in use.';
      case 'weak-password': return 'The password is too weak.';
      case 'invalid-email': return 'Invalid email format.';
      default: return 'An error occurred during sign up.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Create Account'),
        backgroundColor: AppColors.knuRed,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Join KNU Exchange',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.knuRed),
            ),
            const SizedBox(height: 8),
            const Text('Start your KNU campus life today.', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 32),

            SignUpForm(
              formKey: _formKey,
              emailController: _emailController,
              nicknameController: _nicknameController,
              passwordController: _passwordController,
              confirmPasswordController: _confirmPasswordController,
              isLoading: authProvider.isLoading,
              onSubmit: _submit,
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Checkbox(
                  value: _isEulaAgreed,
                  onChanged: (val) => setState(() => _isEulaAgreed = val ?? false),
                  activeColor: AppColors.knuRed,
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      // 상세 약관 다이얼로그 추가 가능
                    },
                    child: const Text(
                      'I agree to the Terms of Service (EULA). We have zero tolerance for objectionable content or abusive users.',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
            _buildLoginLink(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Already have an account?"),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Login',
            style: TextStyle(color: AppColors.knuRed, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}