import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../config/app_theme.dart';
import '../../../config/constants.dart';
import '../../../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String _gender = 'ذكر';
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.signUp(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      phone: _phoneController.text.trim().isNotEmpty
          ? _phoneController.text.trim()
          : null,
      gender: _gender,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(Constants.registerSuccess),
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_forward_ios, color: AppTheme.darkText),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'إنشاء حساب جديد',
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
                  'أدخل بياناتك لإنشاء حساب',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14,
                    color: AppTheme.greyText,
                  ),
                ),
                const SizedBox(height: 28),
                TextFormField(
                  controller: _nameController,
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    color: AppTheme.darkText,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'الاسم الكامل',
                    prefixIcon: Icon(Icons.person_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return Constants.requiredField;
                    }
                    if (value.trim().length < 3) {
                      return Constants.nameTooShort;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
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
                const SizedBox(height: 14),
                TextFormField(
                  controller: _phoneController,
                  textDirection: TextDirection.ltr,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    color: AppTheme.darkText,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'رقم الهاتف (اختياري)',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.lightGrey),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.wc_outlined, color: AppTheme.greyText),
                      const SizedBox(width: 10),
                      const Text(
                        'الجنس',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 14,
                          color: AppTheme.greyText,
                        ),
                      ),
                      const Spacer(),
                      Radio<String>(
                        value: 'ذكر',
                        groupValue: _gender,
                        onChanged: (val) => setState(() => _gender = val!),
                        activeColor: AppTheme.primaryBlue,
                      ),
                      const Text(
                        'ذكر',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 13,
                          color: AppTheme.darkText,
                        ),
                      ),
                      Radio<String>(
                        value: 'أنثى',
                        groupValue: _gender,
                        onChanged: (val) => setState(() => _gender = val!),
                        activeColor: AppTheme.primaryBlue,
                      ),
                      const Text(
                        'أنثى',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 13,
                          color: AppTheme.darkText,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
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
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
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
                const SizedBox(height: 14),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    color: AppTheme.darkText,
                  ),
                  decoration: InputDecoration(
                    labelText: 'تأكيد كلمة المرور',
                    prefixIcon: const Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppTheme.greyText,
                      ),
                      onPressed: () => setState(
                        () => _obscureConfirmPassword = !_obscureConfirmPassword,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return Constants.requiredField;
                    }
                    if (value != _passwordController.text) {
                      return Constants.passwordsDoNotMatch;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 28),
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: authProvider.isLoading ? null : _register,
                    child: authProvider.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: AppTheme.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('إنشاء الحساب'),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'لديك حساب بالفعل؟',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 14,
                        color: AppTheme.greyText,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.push('/login'),
                      child: const Text(
                        'تسجيل الدخول',
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
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
