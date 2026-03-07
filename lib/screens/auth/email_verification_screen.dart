import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_colors.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // EmailVerificationScreen 내부의 타이머 부분 수정
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // checkEmailVerified가 내부에서 isAuthenticated 상태를 업데이트합니다.
      bool isVerified = await authProvider.checkEmailVerified();

      if (isVerified && mounted) {
        _timer?.cancel();
        // 여기서 '/'로 이동하면 AuthProvider의 isAuthenticated가 true이므로 메인으로 갑니다.
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      }
    });
  }

  void _onVerificationSuccess() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Email verified successfully!')),
    );
    // 자동 로그인을 원하면 여기서 메인 화면으로, 아니면 로그인 페이지로 이동
    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Email'),
        backgroundColor: AppColors.knuRed,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.mark_email_unread_outlined, size: 80, color: AppColors.knuRed),
            const SizedBox(height: 24),
            const Text(
              'Check your inbox!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'A verification email has been sent to your address.\nPlease click the link in the email to complete your registration.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20), // 간격 추가

// [추가] 스팸함 확인 안내 문구
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                '(Note: If you do not see the email, please check your spam folder, especially for Gmail users.)',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(color: AppColors.knuRed),
            const SizedBox(height: 16),
            const Text('Waiting for verification...', style: TextStyle(fontStyle: FontStyle.italic)),
            const SizedBox(height: 48),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel and go back', style: TextStyle(color: Colors.grey)),
            ),
          ],
        ),
      ),
    );
  }
}