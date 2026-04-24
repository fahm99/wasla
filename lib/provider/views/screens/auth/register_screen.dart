import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import '../../../config/app_theme.dart';
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
  final _institutionNameController = TextEditingController();

  String? _institutionType;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _institutionNameController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يجب الموافقة على الشروط والأحكام'),
          backgroundColor: AppTheme.redDanger,
        ),
      );
      return;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('كلمة المرور غير متطابقة'),
          backgroundColor: AppTheme.redDanger,
        ),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.signUp(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim().isNotEmpty
          ? _phoneController.text.trim()
          : null,
      institutionType: _institutionType,
      institutionName: _institutionNameController.text.trim().isNotEmpty
          ? _institutionNameController.text.trim()
          : null,
    );

    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم إنشاء الحساب بنجاح!'),
          backgroundColor: AppTheme.greenSuccess,
        ),
      );
      context.go('/dashboard');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error ?? 'فشل في إنشاء الحساب'),
          backgroundColor: AppTheme.redDanger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_forward_ios,
                color: AppTheme.primaryDarkBlue),
            onPressed: () => context.pop(),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'إنشاء حساب جديد',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryDarkBlue,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'أنشئ حسابك كبزود محتوى تعليمي',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.darkGrayText,
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Name
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'الاسم الكامل',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'الاسم مطلوب';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Email
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textDirection: TextDirection.ltr,
                      textAlign: TextAlign.right,
                      decoration: const InputDecoration(
                        labelText: 'البريد الإلكتروني',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'البريد الإلكتروني مطلوب';
                        }
                        if (!value.contains('@')) {
                          return 'البريد الإلكتروني غير صحيح';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Phone
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      textDirection: TextDirection.ltr,
                      textAlign: TextAlign.right,
                      decoration: const InputDecoration(
                        labelText: 'رقم الهاتف',
                        prefixIcon: Icon(Icons.phone_outlined),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Institution Type
                    DropdownButtonFormField2<String>(
                      value: _institutionType,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'نوع المؤسسة',
                        prefixIcon: Icon(Icons.business_outlined),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'جامعة', child: Text('جامعة')),
                        DropdownMenuItem(value: 'مدرسة', child: Text('مدرسة')),
                        DropdownMenuItem(value: 'معهد', child: Text('معهد')),
                        DropdownMenuItem(
                            value: 'مركز تدريب', child: Text('مركز تدريب')),
                        DropdownMenuItem(value: 'أخرى', child: Text('أخرى')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _institutionType = value;
                        });
                      },
                      buttonStyleData: const ButtonStyleData(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                      ),
                      dropdownStyleData: DropdownStyleData(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Institution Name
                    TextFormField(
                      controller: _institutionNameController,
                      decoration: const InputDecoration(
                        labelText: 'اسم المؤسسة',
                        prefixIcon: Icon(Icons.account_balance_outlined),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Password
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'كلمة المرور',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'كلمة المرور مطلوبة';
                        }
                        if (value.length < 6) {
                          return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Confirm Password
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      decoration: InputDecoration(
                        labelText: 'تأكيد كلمة المرور',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword =
                                  !_obscureConfirmPassword;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'تأكيد كلمة المرور مطلوب';
                        }
                        if (value != _passwordController.text) {
                          return 'كلمة المرور غير متطابقة';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Terms checkbox
                    Row(
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: Checkbox(
                            value: _acceptTerms,
                            onChanged: (value) {
                              setState(() {
                                _acceptTerms = value ?? false;
                              });
                            },
                            activeColor: AppTheme.primaryDarkBlue,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _acceptTerms = !_acceptTerms;
                              });
                            },
                            child: const Text(
                              'أوافق على الشروط والأحكام وسياسة الخصوصية',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppTheme.darkGrayText,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    // Register Button
                    Consumer<AuthProvider>(
                      builder: (context, authProvider, child) {
                        return SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed:
                                authProvider.isLoading ? null : _register,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryDarkBlue,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: authProvider.isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'إنشاء الحساب',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    // Login link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'لديك حساب بالفعل؟ ',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.darkGrayText,
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.pop(),
                          child: const Text(
                            'تسجيل الدخول',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
