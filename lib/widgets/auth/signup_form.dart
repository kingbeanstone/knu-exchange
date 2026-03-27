import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

class SignUpForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController nicknameController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final bool isLoading;
  final VoidCallback onSubmit;

  const SignUpForm({
    super.key,
    required this.formKey,
    required this.emailController,
    required this.nicknameController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.isLoading,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          // 이메일 필드
          TextFormField(
            controller: emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
              hintText: 'example@gmail.com',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.email_outlined),
            ),
            keyboardType: TextInputType.emailAddress,
            enabled: !isLoading,
            validator: (val) {
              if (val == null || val.isEmpty) return 'Please enter your email.';
              if (!val.contains('@') || !val.contains('.')) return 'Please enter a valid email address.';
              return null;
            },
          ),
          const SizedBox(height: 16),

          // 닉네임 필드
          TextFormField(
            controller: nicknameController,
            decoration: const InputDecoration(
              labelText: 'Nickname',
            hintText: 'Enter the name you want to use in the app',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person_outline),
            ),
            enabled: !isLoading,
            validator: (val) {
              if (val == null || val.isEmpty) return 'Please enter a nickname.';
              if (val.length < 2) return 'Nickname must be at least 2 characters.';
              return null;
            },
          ),
          const SizedBox(height: 16),

          // 비밀번호 필드
          TextFormField(
            controller: passwordController,
            decoration: const InputDecoration(
              labelText: 'Password',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.lock_outline),
            ),
            obscureText: true,
            enabled: !isLoading,
            validator: (val) => (val?.length ?? 0) < 6 ? 'Password must be at least 6 characters.' : null,
          ),
          const SizedBox(height: 16),

          // 비밀번호 확인 필드
          TextFormField(
            controller: confirmPasswordController,
            decoration: const InputDecoration(
              labelText: 'Confirm Password',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.lock_reset_outlined),
            ),
            obscureText: true,
            enabled: !isLoading,
            validator: (val) {
              if (val != passwordController.text) return 'Passwords do not match.';
              return null;
            },
          ),
          const SizedBox(height: 32),

          // 가입 버튼
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: isLoading ? null : onSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.knuRed,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: isLoading
                  ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
                  : const Text('Sign Up', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}