import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/app_theme.dart';
import '../../../config/constants.dart';
import '../../../providers/auth_provider.dart';
import '../../../widgets/custom_app_bar.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success =
        await authProvider.updatePassword(_newPasswordController.text.trim());

    setState(() => _isSubmitting = false);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'تم تغيير كلمة المرور بنجاح',
            style: TextStyle(fontFamily: 'Cairo'),
          ),
          backgroundColor: AppTheme.greenSuccess,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            authProvider.errorMessage ?? Constants.msgError,
            style: const TextStyle(fontFamily: 'Cairo'),
          ),
          backgroundColor: AppTheme.redDanger,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppTheme.lightGrayBg,
        appBar: const CustomAppBar(
          title: Constants.titleChangePassword,
          showBack: true,
          backgroundColor: AppTheme.primaryDarkBlue,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Info Box
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.blueInfo.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppTheme.blueInfo.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline,
                          color: AppTheme.blueInfo),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'كلمة المرور يجب أن تكون 8 أحرف على الأقل وتحتوي على حرف كبير وصغير ورقم',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 12,
                            color: AppTheme.blueInfo.withOpacity(0.8),
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                // Current Password
                const Text(
                  Constants.hintCurrentPassword,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryDarkBlue,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _currentPasswordController,
                  obscureText: _obscureCurrent,
                  textDirection: TextDirection.ltr,
                  decoration: InputDecoration(
                    hintText: '••••••••',
                    prefixIcon: const Icon(Icons.lock_outline,
                        color: AppTheme.darkGrayText),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureCurrent
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: AppTheme.darkGrayText,
                      ),
                      onPressed: () {
                        setState(() => _obscureCurrent = !_obscureCurrent);
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'يرجى إدخال كلمة المرور الحالية';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                // New Password
                const Text(
                  Constants.hintNewPassword,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryDarkBlue,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _newPasswordController,
                  obscureText: _obscureNew,
                  textDirection: TextDirection.ltr,
                  decoration: InputDecoration(
                    hintText: '••••••••',
                    prefixIcon: const Icon(Icons.lock_outline,
                        color: AppTheme.darkGrayText),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureNew
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: AppTheme.darkGrayText,
                      ),
                      onPressed: () {
                        setState(() => _obscureNew = !_obscureNew);
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'يرجى إدخال كلمة المرور الجديدة';
                    }
                    if (value.length < 8) {
                      return 'كلمة المرور يجب أن تكون 8 أحرف على الأقل';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                // Confirm Password
                const Text(
                  Constants.hintConfirmPassword,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryDarkBlue,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirm,
                  textDirection: TextDirection.ltr,
                  decoration: InputDecoration(
                    hintText: '••••••••',
                    prefixIcon: const Icon(Icons.lock_outline,
                        color: AppTheme.darkGrayText),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirm
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: AppTheme.darkGrayText,
                      ),
                      onPressed: () {
                        setState(() => _obscureConfirm = !_obscureConfirm);
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'يرجى تأكيد كلمة المرور';
                    }
                    if (value != _newPasswordController.text) {
                      return 'كلمتا المرور غير متطابقتين';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _changePassword,
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
                            'تغيير كلمة المرور',
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
        ),
      ),
    );
  }
}
