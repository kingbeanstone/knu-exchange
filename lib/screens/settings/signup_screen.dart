import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import '../auth/email_verification_screen.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_colors.dart';
import '../../widgets/auth/signup_form.dart';
import '../settings/terms_of_service_screen.dart';
import '../settings/privacy_policy_screen.dart';

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

    if (!_isEulaAgreed) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You must agree to the Terms of Service and Privacy Policy to continue.'))
      );
      return;
    }

    FocusScope.of(context).unfocus();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();

    try {
      // 1. 먼저 회원가입 시도
      await authProvider.signUp(
        email,
        password,
        nickname: _nicknameController.text.trim(),
      );

      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const EmailVerificationScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        // 2. 만약 이미 가입된 이메일이라면?
        if (e.code == 'email-already-in-use') {
          try {
            // 입력한 비밀번호로 로그인을 시도해봅니다.
            await authProvider.login(email, password);

            // 로그인이 성공했다면 이미 인증된 계정이므로 메인으로 이동하거나 처리 (필요시)
            // 여기서는 일단 인증 페이지로 보내는 로직에 집중합니다.
          } on FirebaseAuthException catch (loginError) {
            // AuthProvider.login은 이메일 미인증 시 'email-not-verified' 에러를 던집니다.
            if (loginError.code == 'email-not-verified') {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const EmailVerificationScreen()),
              );
              return; // 에러 메시지 없이 바로 이동
            }
            // 비밀번호가 틀린 경우 등은 기존처럼 에러 메시지 표시
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(_getErrorMessage(loginError.code)))
            );
          }
        } else {
          // 중복 이메일 외의 다른 가입 에러 처리
          String msg = _getErrorMessage(e.code);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
        }
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
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                      children: [
                        const TextSpan(text: 'I agree to the '),
                        TextSpan(
                          text: 'Terms of Service',
                          style: const TextStyle(
                            color: AppColors.knuRed,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const TermsOfServiceScreen(),
                                ),
                              );
                            },
                        ),
                        const TextSpan(text: ' and '),
                        TextSpan(
                          text: 'Privacy Policy',
                          style: const TextStyle(
                            color: AppColors.knuRed,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const PrivacyPolicyScreen(),
                                ),
                              );
                            },
                        ),
                        const TextSpan(text: '.'),
                      ],
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