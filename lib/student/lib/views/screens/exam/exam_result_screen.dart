import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../config/app_theme.dart';
import '../../../providers/exam_provider.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/loading_widget.dart';

class ExamResultScreen extends StatefulWidget {
  final String examId;
  final String attemptId;

  const ExamResultScreen({
    super.key,
    required this.examId,
    required this.attemptId,
  });

  @override
  State<ExamResultScreen> createState() => _ExamResultScreenState();
}

class _ExamResultScreenState extends State<ExamResultScreen> {
  @override
  void initState() {
    super.initState();
    _loadResult();
  }

  Future<void> _loadResult() async {
    await context.read<ExamProvider>().loadExamResult(widget.attemptId);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExamProvider>();
    final result = provider.examResult;

    if (provider.isLoading) {
      return Scaffold(
        appBar: const CustomAppBar(title: 'نتيجة الاختبار', showBack: true),
        body: const LoadingWidget(message: 'جاري تحميل النتيجة...'),
      );
    }

    if (result == null) {
      return Scaffold(
        appBar: const CustomAppBar(title: 'نتيجة الاختبار', showBack: true),
        body: const Center(child: Text('لم يتم العثور على النتيجة')),
      );
    }

    final score = (result['score'] is int) ? (result['score'] as int).toDouble() : (result['score'] ?? 0).toDouble();
    final totalPoints = (result['total_points'] is int) ? (result['total_points'] as int).toDouble() : (result['total_points'] ?? 100).toDouble();
    final passed = result['passed'] ?? false;
    final percentage = totalPoints > 0 ? (score / totalPoints) * 100 : 0;

    return Scaffold(
      backgroundColor: AppTheme.lightBg,
      appBar: const CustomAppBar(title: 'نتيجة الاختبار', showBack: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: passed ? AppTheme.successGreen : AppTheme.dangerRed,
                boxShadow: [
                  BoxShadow(
                    color: (passed ? AppTheme.successGreen : AppTheme.dangerRed).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      passed ? Icons.check_circle_outline : Icons.cancel_outlined,
                      size: 48,
                      color: AppTheme.white,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${percentage.toStringAsFixed(0)}%',
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              passed ? 'تهانينا! لقد نجحت' : 'للأسف لم تنجح',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: passed ? AppTheme.successGreen : AppTheme.dangerRed,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              passed ? 'استمر في التقدم' : 'حاول مرة أخرى',
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 14,
                color: AppTheme.greyText,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildResultRow('الدرجة', '$score / $totalPoints'),
                  const Divider(height: 32),
                  _buildResultRow('النسبة المئوية', '${percentage.toStringAsFixed(1)}%'),
                  const Divider(height: 32),
                  _buildResultRow('النتيجة', passed ? 'ناجح' : 'راسب'),
                  const Divider(height: 32),
                  _buildResultRow('الوقت المستغرق', '${result['time_spent'] ?? 0} ثانية'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 48,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.go('/home'),
                child: const Text('العودة للرئيسية'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 14,
            color: AppTheme.greyText,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppTheme.darkText,
          ),
        ),
      ],
    );
  }
}
