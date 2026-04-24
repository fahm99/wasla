import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
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
  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.login(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    setState(() => _isSubmitting = false);

    if (!mounted) return;

    if (success) {
      context.go('/dashboard');
    } else {
      _showError(authProvider.errorMessage ?? Constants.msgLoginError);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontFamily: 'Cairo'),
        ),
        backgroundColor: AppTheme.redDanger,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppTheme.white,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 60),
                  // Logo
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppTheme.yellowAccent,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.yellowAccent.withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'وصلة',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primaryDarkBlue,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    Constants.appSubtitle,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.darkGrayText,
                    ),
                  ),
                  const SizedBox(height: 48),
                  // Form
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          Constants.titleLogin,
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primaryDarkBlue,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'أدخل بيانات المشرف للوصول إلى لوحة التحكم',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 13,
                            color: AppTheme.darkGrayText,
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Email
                        const Text(
                          Constants.hintEmail,
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryDarkBlue,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textDirection: TextDirection.ltr,
                          textAlign: TextAlign.right,
                          decoration: InputDecoration(
                            hintText: 'example@email.com',
                            prefixIcon: const Icon(Icons.email_outlined,
                                color: AppTheme.darkGrayText),
                            hintStyle: const TextStyle(
                              fontFamily: 'Cairo',
                              color: AppTheme.darkGrayText,
                              fontSize: 13,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'يرجى إدخال البريد الإلكتروني';
                            }
                            if (!value.contains('@')) {
                              return 'يرجى إدخال بريد إلكتروني صحيح';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        // Password
                        const Text(
                          Constants.hintPassword,
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryDarkBlue,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          textDirection: TextDirection.ltr,
                          textAlign: TextAlign.right,
                          decoration: InputDecoration(
                            hintText: '••••••••',
                            prefixIcon: const Icon(Icons.lock_outlined,
                                color: AppTheme.darkGrayText),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: AppTheme.darkGrayText,
                              ),
                              onPressed: () {
                                setState(
                                    () => _obscurePassword = !_obscurePassword);
                              },
                            ),
                            hintStyle: const TextStyle(
                              fontFamily: 'Cairo',
                              color: AppTheme.darkGrayText,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'يرجى إدخال كلمة المرور';
                            }
                            if (value.length < 6) {
                              return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 32),
                        // Login Button
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _isSubmitting ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryDarkBlue,
                              foregroundColor: AppTheme.white,
                              disabledBackgroundColor:
                                  AppTheme.primaryDarkBlue.withOpacity(0.6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isSubmitting
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          AppTheme.white),
                                    ),
                                  )
                                : const Text(
                                    'تسجيل الدخول',
                                    style: TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
