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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  // 에러 메시지 영문으로 변경
  String _getErrorMessage(String code) {
    switch (code) {
      case 'email-already-in-use': return 'This email is already in use.';
      case 'weak-password': return 'The password is too weak.';
      case 'invalid-email': return 'Invalid email format.';
      default: return 'An error occurred during sign up.';
    }
  }

  // 성공 다이얼로그 문구 수정 (스팸함 확인 안내 추가)
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Verification Email Sent'),
        content: const Text(
          'A verification email has been sent to your address.\nPlease click the link in the email to complete your registration.\n\n(Note: If you do not see the email, please check your spam folder, especially for Gmail users.)',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('OK'),
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
            // 요청하신 문구 영문으로 변경
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