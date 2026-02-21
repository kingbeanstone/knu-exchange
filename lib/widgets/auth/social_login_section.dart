import 'dart:io';
import 'package:flutter/material.dart';
import 'social_login_button.dart';

class SocialLoginSection extends StatelessWidget {
  // onGoogleSignIn 파라미터 제거됨
  final VoidCallback onAppleSignIn;

  const SocialLoginSection({
    super.key,
    required this.onAppleSignIn,
  });

  @override
  Widget build(BuildContext context) {
    // 애플 로그인 버튼만 남았으므로, iOS가 아닐 경우 섹션 자체를 숨길 수도 있습니다.
    if (!Platform.isIOS) return const SizedBox.shrink();

    return Column(
      children: [
        Row(
          children: [
            const Expanded(child: Divider()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "OR",
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              ),
            ),
            const Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: 32),

        // 구글 로그인 버튼 제거됨

        // 애플 로그인 버튼
        SocialLoginButton(
          label: "Sign in with Apple",
          icon: const Icon(Icons.apple, color: Colors.white, size: 26),
          backgroundColor: Colors.black,
          textColor: Colors.white,
          onPressed: onAppleSignIn,
        ),
      ],
    );
  }
}