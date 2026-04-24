import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../config/app_theme.dart';
import '../../../config/constants.dart';
import '../../../providers/course_provider.dart';
import '../../../providers/enrollment_provider.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/loading_widget.dart';

class EnrollScreen extends StatefulWidget {
  final String courseId;

  const EnrollScreen({super.key, required this.courseId});

  @override
  State<EnrollScreen> createState() => _EnrollScreenState();
}

class _EnrollScreenState extends State<EnrollScreen> {
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    context.read<CourseProvider>().loadCourseById(widget.courseId);
  }

  Future<void> _enroll() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final success = await context.read<EnrollmentProvider>().enrollInCourse(widget.courseId);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(Constants.enrollSuccess),
              backgroundColor: AppTheme.successGreen,
            ),
          );
          context.go('/courses/${widget.courseId}/content');
        } else {
          final error = context.read<EnrollmentProvider>().error;
          setState(() => _error = error ?? Constants.generalError);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = Constants.generalError);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final courseProvider = context.watch<CourseProvider>();
    final course = courseProvider.currentCourse;

    return Scaffold(
      backgroundColor: AppTheme.lightBg,
      appBar: const CustomAppBar(title: 'التسجيل في الدورة', showBack: true),
      body: courseProvider.isLoading
          ? const LoadingWidget(message: 'جاري تحميل...')
          : course == null
              ? const Center(child: Text('الدورة غير موجودة'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppTheme.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'ملخص التسجيل',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.darkText,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildSummaryRow('الدورة', course.title),
                            const SizedBox(height: 8),
                            _buildSummaryRow('المدرب', course.providerName ?? '-'),
                            const SizedBox(height: 8),
                            _buildSummaryRow('المدة', course.formattedDuration),
                            const SizedBox(height: 8),
                            _buildSummaryRow('المستوى', course.level),
                            const Divider(height: 32),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'المبلغ الإجمالي',
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.darkText,
                                  ),
                                ),
                                Text(
                                  course.formattedPrice,
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: course.price == 0 ? AppTheme.successGreen : AppTheme.primaryBlue,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.dangerRed.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline, color: AppTheme.dangerRed),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _error!,
                                  style: const TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 13,
                                    color: AppTheme.dangerRed,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _enroll,
                          child: _isLoading
                              ? const CircularProgressIndicator(color: AppTheme.white)
                              : Text(
                                  course.price == 0 ? 'سجل مجاناً الآن' : 'تأكيد التسجيل',
                                  style: const TextStyle(
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
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 13,
              color: AppTheme.greyText,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.darkText,
            ),
          ),
        ),
      ],
    );
  }
}
