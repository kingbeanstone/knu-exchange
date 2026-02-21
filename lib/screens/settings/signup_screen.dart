import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
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

  @override
  void dispose() {
    _emailController.dispose();
    _nicknameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      await authProvider.signUp(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        nickname: _nicknameController.text.trim(),
      );

      if (mounted) {
        _showSuccessDialog();
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        String msg = _getErrorMessage(e.code);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('에러: $e')));
      }
    }
  }

  String _getErrorMessage(String code) {
    switch (code) {
      case 'email-already-in-use': return '이미 사용 중인 이메일입니다.';
      case 'weak-password': return '비밀번호가 너무 취약합니다.';
      case 'invalid-email': return '유효하지 않은 이메일 형식입니다.';
      default: return '회원가입 중 오류가 발생했습니다.';
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('인증 메일 발송'),
        content: const Text(
          '가입하신 이메일로 인증 메일을 보냈습니다.\n메일함의 링크를 클릭하여 인증을 완료해주세요.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('확인'),
          ),
        ],
      ),
    );
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
            const Text('경북대 캠퍼스 라이프를 시작해보세요.', style: TextStyle(color: Colors.grey)),
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

            // [삭제] 소셜 로그인 섹션(구글/애플)이 제거되었습니다.

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