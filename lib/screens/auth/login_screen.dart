import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import '../../providers/auth_provider.dart';
import '../../utils/app_colors.dart';
import '../../widgets/auth/auth_header.dart';
import '../../widgets/auth/login_form.dart';
import '../settings/signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // [Update] Developer Test Account List
  final List<Map<String, String>> _devAccounts = [
    {'name': 'HJ', 'email': 'wlsgudwns112@naver.com', 'pw': '123456'},
    {'name': 'HJ 2', 'email': 'wlsgudwns112@gmail.com', 'pw': '123456'},
    {'name': 'Test Student 2', 'email': 'student2@knu.ac.kr', 'pw': 'password123'},
    {'name': 'Foreigner User', 'email': 'global@knu.ac.kr', 'pw': 'password123'},
  ];

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Fill input fields with selected account
  void _fillAccount(String email, String password) {
    setState(() {
      _emailController.text = email;
      _passwordController.text = password;
    });
  }

  // Callback for LoginForm to fill debug info
  void _fillDebugInfo() {
    _fillAccount("wlsgudwns112@naver.com", "123456");
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      await authProvider.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.message ?? 'Login failed.'))
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const AuthHeader(),
              const SizedBox(height: 40),

              // Login Form Widget
              LoginForm(
                formKey: _formKey,
                emailController: _emailController,
                passwordController: _passwordController,
                isLoading: authProvider.isLoading,
                onSubmit: _submit,
                onFillDebug: _fillDebugInfo,
              ),

              const SizedBox(height: 16),

              // Developer account selection dropdown
              PopupMenuButton<Map<String, String>>(
                onSelected: (account) {
                  _fillAccount(account['email']!, account['pw']!);
                },
                itemBuilder: (BuildContext context) {
                  return _devAccounts.map((account) {
                    return PopupMenuItem<Map<String, String>>(
                      value: account,
                      child: Row(
                        children: [
                          const Icon(Icons.person_outline, size: 20, color: Colors.grey),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(account['name']!,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              Text(account['email']!,
                                  style: const TextStyle(fontSize: 11, color: Colors.grey)),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.bug_report, size: 16, color: Colors.orange),
                      const SizedBox(width: 8),
                      Text('Select Test Account', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                      const Icon(Icons.arrow_drop_down, color: Colors.grey),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),
              _buildSignUpLink(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSignUpLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Don't have an account?"),
        TextButton(
          onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SignUpScreen())
          ),
          child: const Text(
              'Sign Up',
              style: TextStyle(color: AppColors.knuRed, fontWeight: FontWeight.bold)
          ),
        ),
      ],
    );
  }
}