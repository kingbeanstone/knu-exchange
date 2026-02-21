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
              hintText: 'example@knu.ac.kr',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.email_outlined),
            ),
            keyboardType: TextInputType.emailAddress,
            enabled: !isLoading,
            validator: (val) {
              if (val == null || val.isEmpty) return '이메일을 입력해주세요.';
              if (!val.contains('@') || !val.contains('.')) return '올바른 이메일 형식이 아닙니다.';
              return null;
            },
          ),
          const SizedBox(height: 16),

          // 닉네임 필드
          TextFormField(
            controller: nicknameController,
            decoration: const InputDecoration(
              labelText: 'Nickname',
              hintText: '앱에서 사용할 이름을 입력하세요',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person_outline),
            ),
            enabled: !isLoading,
            validator: (val) {
              if (val == null || val.isEmpty) return '닉네임을 입력해주세요.';
              if (val.length < 2) return '닉네임은 최소 2자 이상이어야 합니다.';
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
            validator: (val) => (val?.length ?? 0) < 6 ? '비밀번호는 최소 6자 이상입니다.' : null,
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
              if (val != passwordController.text) return '비밀번호가 일치하지 않습니다.';
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