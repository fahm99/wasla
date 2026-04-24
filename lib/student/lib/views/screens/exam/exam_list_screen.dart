import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../config/app_theme.dart';
import '../../../providers/exam_provider.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/exam_card.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/loading_widget.dart';

class ExamListScreen extends StatefulWidget {
  final String courseId;

  const ExamListScreen({super.key, required this.courseId});

  @override
  State<ExamListScreen> createState() => _ExamListScreenState();
}

class _ExamListScreenState extends State<ExamListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ExamProvider>().loadExamsByCourse(widget.courseId);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExamProvider>();

    return Scaffold(
      backgroundColor: AppTheme.lightBg,
      appBar: const CustomAppBar(title: 'الاختبارات', showBack: true),
      body: provider.isLoading
          ? const LoadingWidget(message: 'جاري تحميل الاختبارات...')
          : provider.exams.isEmpty
              ? const EmptyState(
                  icon: Icons.quiz_outlined,
                  title: 'لا توجد اختبارات',
                  subtitle: 'لم يتم إضافة اختبارات لهذه الدورة بعد',
                )
              : RefreshIndicator(
                  color: AppTheme.primaryBlue,
                  onRefresh: () => provider.loadExamsByCourse(widget.courseId),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: provider.exams.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final exam = provider.exams[index];
                      return ExamCard(
                        exam: exam,
                        onTap: exam.canAttempt
                            ? () => context.push('/exams/${exam.id}/take')
                            : () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('لقد استنفدت جميع المحاولات'),
                                    backgroundColor: AppTheme.dangerRed,
                                  ),
                                );
                              },
                      );
                    },
                  ),
                ),
    );
  }
}
