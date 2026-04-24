import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../config/app_theme.dart';
import '../../../config/constants.dart';
import '../../../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(Constants.loginSuccess),
          backgroundColor: AppTheme.successGreen,
        ),
      );
      context.go('/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error ?? Constants.generalError),
          backgroundColor: AppTheme.dangerRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppTheme.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Center(
                    child: Text(
                      'وسلة',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'منصة وسلة التعليمية',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 16,
                    color: AppTheme.greyText,
                  ),
                ),
                const SizedBox(height: 40),
                const Text(
                  'تسجيل الدخول',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.darkText,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'أدخل بياناتك للمتابعة',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14,
                    color: AppTheme.greyText,
                  ),
                ),
                const SizedBox(height: 32),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _emailController,
                        textDirection: TextDirection.ltr,
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          color: AppTheme.darkText,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'البريد الإلكتروني',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return Constants.requiredField;
                          }
                          final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                          if (!regex.hasMatch(value)) {
                            return Constants.invalidEmail;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          color: AppTheme.darkText,
                        ),
                        decoration: InputDecoration(
                          labelText: 'كلمة المرور',
                          prefixIcon: const Icon(Icons.lock_outlined),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: AppTheme.greyText,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return Constants.requiredField;
                          }
                          if (value.length < 8) {
                            return Constants.passwordTooShort;
                          }
                          return null;
                        },
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          onPressed: () async {
                            if (_emailController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('أدخل البريد الإلكتروني أولاً'),
                                  backgroundColor: AppTheme.dangerRed,
                                ),
                              );
                              return;
                            }
                            final success = await authProvider.resetPassword(
                              _emailController.text.trim(),
                            );
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(success
                                    ? 'تم إرسال رابط إعادة تعيين كلمة المرور'
                                    : authProvider.error ?? Constants.generalError),
                                backgroundColor: success
                                    ? AppTheme.successGreen
                                    : AppTheme.dangerRed,
                              ),
                            );
                          },
                          child: const Text(
                            'نسيت كلمة المرور؟',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 12,
                              color: AppTheme.primaryBlue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: authProvider.isLoading ? null : _login,
                          child: authProvider.isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: AppTheme.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('تسجيل الدخول'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'ليس لديك حساب؟',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 14,
                        color: AppTheme.greyText,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.push('/register'),
                      child: const Text(
                        'إنشاء حساب',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 14,
                          color: AppTheme.primaryBlue,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
