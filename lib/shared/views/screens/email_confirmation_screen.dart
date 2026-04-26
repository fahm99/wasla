import 'package:flutter/material.dart';

/// شاشة تأكيد البريد الإلكتروني
/// Email Confirmation Screen
class EmailConfirmationScreen extends StatelessWidget {
  final String email;
  final VoidCallback? onResendEmail;

  const EmailConfirmationScreen({
    super.key,
    required this.email,
    this.onResendEmail,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('تأكيد البريد الإلكتروني'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // أيقونة البريد
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.email_outlined,
                  size: 60,
                  color: Colors.blue.shade600,
                ),
              ),

              const SizedBox(height: 32),

              // العنوان
              const Text(
                'تحقق من بريدك الإلكتروني',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // الوصف
              Text(
                'لقد أرسلنا رابط تأكيد إلى:',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                  fontFamily: 'Cairo',
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              // البريد الإلكتروني
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  email,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Cairo',
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 24),

              // التعليمات
              Text(
                'يرجى النقر على الرابط في البريد الإلكتروني لتفعيل حسابك',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  fontFamily: 'Cairo',
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 48),

              // زر إعادة الإرسال
              if (onResendEmail != null)
                OutlinedButton.icon(
                  onPressed: onResendEmail,
                  icon: const Icon(Icons.refresh),
                  label: const Text(
                    'إعادة إرسال البريد',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 16,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

              const SizedBox(height: 16),

              // زر العودة
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'العودة لتسجيل الدخول',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 16,
                  ),
                ),
              ),

              const Spacer(),

              // ملاحظة
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.amber.shade200,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.amber.shade700,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'لم تستلم البريد؟ تحقق من مجلد الرسائل غير المرغوب فيها (Spam)',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.amber.shade900,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
