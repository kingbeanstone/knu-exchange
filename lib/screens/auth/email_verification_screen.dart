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
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                const SizedBox(height: 40),

                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF5F5F5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.mark_email_unread_outlined,
                    size: 64,
                    color: AppColors.knuRed,
                  ),
                ),

                const SizedBox(height: 32),

                const Text(
                  'Check your email',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                const Text(
                  'We sent a verification link to your email address.\nPlease verify your email to continue.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 20),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'If you do not see the email, please check your spam folder (especially for Gmail users).',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                const CircularProgressIndicator(
                  color: AppColors.knuRed,
                ),

                const SizedBox(height: 16),

                const Text(
                  'Waiting for verification...',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(height: 40),

                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'Cancel and go back',
                    style: TextStyle(color: Colors.black),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}