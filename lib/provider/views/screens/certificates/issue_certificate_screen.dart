import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/app_theme.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/certificate_provider.dart';
import '../../../widgets/custom_app_bar.dart';

class IssueCertificateScreen extends StatefulWidget {
  final String courseId;
  final String courseName;

  const IssueCertificateScreen({
    super.key,
    required this.courseId,
    this.courseName = '',
  });

  @override
  State<IssueCertificateScreen> createState() => _IssueCertificateScreenState();
}

class _IssueCertificateScreenState extends State<IssueCertificateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _studentNameController = TextEditingController();
  final _scoreController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _studentNameController.dispose();
    _scoreController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    final authProvider = context.read<AuthProvider>();
    final certProvider = context.read<CertificateProvider>();

    final success = await certProvider.issueCertificate(
      studentName: _studentNameController.text.trim(),
      courseName: widget.courseName.isNotEmpty ? widget.courseName : 'دورة تعليمية',
      providerName: authProvider.user?.name ?? '',
      score: double.parse(_scoreController.text.trim()),
      studentId: '',
      courseId: widget.courseId,
      providerId: authProvider.user?.id ?? '',
    );

    setState(() => _isSubmitting = false);
    if (!mounted) return;

    if (success != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إصدار الشهادة بنجاح'), backgroundColor: AppTheme.greenSuccess),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(certProvider.error ?? 'حدث خطأ'), backgroundColor: AppTheme.redDanger),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: const CustomAppBar(title: 'إصدار شهادة'),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.yellowAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.yellowAccent.withOpacity(0.3)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, color: AppTheme.primaryDarkBlue),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'أدخل بيانات الطالب لإصدار شهادة إتمام الدورة',
                          style: TextStyle(fontSize: 13, color: AppTheme.darkGrayText),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _studentNameController,
                  decoration: const InputDecoration(
                    labelText: 'اسم الطالب',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty ? 'اسم الطالب مطلوب' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _scoreController,
                  keyboardType: TextInputType.number,
                  textDirection: TextDirection.ltr,
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(
                    labelText: 'الدرجة (%)',
                    hintText: '85',
                    hintTextDirection: TextDirection.ltr,
                    prefixIcon: Icon(Icons.grade_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'الدرجة مطلوبة';
                    final score = double.tryParse(value.trim());
                    if (score == null || score < 0 || score > 100) return 'القيمة يجب أن تكون بين 0 و 100';
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryDarkBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('إصدار الشهادة', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
