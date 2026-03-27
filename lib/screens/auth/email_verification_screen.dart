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
  int _resendCooldown = 0; // 재발송 대기 시간 (초)
  Timer? _cooldownTimer;
  bool _isResending = false;

  @override
  void initState() {
    super.initState();
    // 3초마다 Firebase 서버에 접속해 인증 여부를 새로고침하여 확인합니다.
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // checkEmailVerified 내부에서 인증이 확인되면 상태가 true로 바뀝니다.
      bool isVerified = await authProvider.checkEmailVerified();

      if (isVerified && mounted) {
        _timer?.cancel();
        _cooldownTimer?.cancel();
        // 인증 성공 시 모든 경로를 제거하고 메인('/')으로 이동합니다.
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _cooldownTimer?.cancel();
    super.dispose();
  }

  /// 인증 메일을 재발송하는 함수
  Future<void> _handleResendEmail() async {
    // 쿨다운 중이거나 이미 요청 중이면 중단
    if (_resendCooldown > 0 || _isResending) return;

    setState(() => _isResending = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      // AuthProvider에 구현된 재발송 로직 호출
      await authProvider.resendVerificationEmail();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('A new verification email has been sent!'),
            backgroundColor: Colors.blue,
          ),
        );

        // 60초 동안 버튼 비활성화 (스팸 방지)
        setState(() {
          _resendCooldown = 60;
          _isResending = false;
        });
        _startCooldownTimer();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isResending = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to resend: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  /// 1초마다 숫자를 줄여주는 쿨다운 타이머
  void _startCooldownTimer() {
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCooldown > 0) {
        setState(() => _resendCooldown--);
      } else {
        _cooldownTimer?.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Email'),
        backgroundColor: AppColors.knuRed,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                const SizedBox(height: 20),

                // 메일 아이콘 영역
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

                // [추가] 인증 메일 재발송 버튼
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: (_resendCooldown > 0 || _isResending) ? null : _handleResendEmail,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.knuRed,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: _isResending
                        ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                    )
                        : Text(
                        _resendCooldown > 0
                            ? 'Resend in ${_resendCooldown}s'
                            : 'Resend Verification Email'
                    ),
                  ),
                ),

                const SizedBox(height: 32),

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
                    style: TextStyle(color: Colors.black54),
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