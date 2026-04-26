import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../config/app_theme.dart';
import '../../../providers/exam_provider.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/loading_widget.dart';
import '../../../widgets/confirmation_dialog.dart';

class ExamsListScreen extends StatefulWidget {
  final String courseId;

  const ExamsListScreen({super.key, required this.courseId});

  @override
  State<ExamsListScreen> createState() => _ExamsListScreenState();
}

class _ExamsListScreenState extends State<ExamsListScreen> {
  @override
  void initState() {
    super.initState();
    _loadExams();
  }

  Future<void> _loadExams() async {
    await context.read<ExamProvider>().loadExams(widget.courseId);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: const CustomAppBar(title: 'إدارة الامتحانات'),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            await context.push('/courses/${widget.courseId}/exams/new');
            _loadExams();
          },
          backgroundColor: AppTheme.primaryDarkBlue,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add),
          label: const Text('إضافة امتحان',
              style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        body: Consumer<ExamProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const LoadingWidget(message: 'جاري تحميل الامتحانات...');
            }
            if (provider.exams.isEmpty) {
              return EmptyState(
                title: 'لا توجد امتحانات',
                message: 'ابدأ بإضافة امتحانات لتقييم الطلاب',
                icon: Icons.quiz_outlined,
                buttonText: 'إضافة امتحان جديد',
                onButtonPressed: () async {
                  await context.push('/courses/${widget.courseId}/exams/new');
                  _loadExams();
                },
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.exams.length,
              itemBuilder: (context, index) {
                final exam = provider.exams[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2)),
                    ],
                  ),
                  child: InkWell(
                    onTap: () => context.push(
                        '/courses/${widget.courseId}/exams/${exam.id}/questions'),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                    color: AppTheme.primaryDarkBlue
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10)),
                                child: const Icon(Icons.quiz,
                                    color: AppTheme.primaryDarkBlue, size: 24),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(exam.title,
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.primaryDarkBlue)),
                                    const SizedBox(height: 4),
                                    Text(
                                      exam.description,
                                      style: const TextStyle(
                                          fontSize: 13,
                                          color: AppTheme.darkGrayText),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _buildChip(
                                  Icons.grade_outlined,
                                  'درجة النجاح: ${exam.passingScore}%',
                                  AppTheme.greenSuccess),
                              const SizedBox(width: 8),
                              if (exam.duration > 0)
                                _buildChip(
                                    Icons.timer_outlined,
                                    '${exam.duration} دقيقة',
                                    AppTheme.blueInfo),
                              const SizedBox(width: 8),
                              _buildChip(
                                  Icons.help_outline,
                                  '${exam.questionsCount ?? 0} سؤال',
                                  AppTheme.yellowAccent),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton.icon(
                                onPressed: () => context.push(
                                    '/courses/${widget.courseId}/exams/${exam.id}/questions'),
                                icon: const Icon(Icons.question_answer_outlined,
                                    size: 18),
                                label: const Text('الأسئلة'),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit_outlined,
                                    size: 20, color: AppTheme.primaryDarkBlue),
                                onPressed: () async {
                                  await context.push(
                                      '/courses/${widget.courseId}/exams/${exam.id}');
                                  _loadExams();
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline,
                                    size: 20, color: AppTheme.redDanger),
                                onPressed: () async {
                                  final confirm = await ConfirmationDialog.show(
                                    context,
                                    title: 'حذف الامتحان',
                                    message:
                                        'هل أنت متأكد من حذف هذا الامتحان؟ سيتم حذف جميع الأسئلة المرتبطة.',
                                    isDanger: true,
                                    confirmText: 'حذف',
                                  );
                                  if (confirm == true) {
                                    await provider.deleteExam(exam.id);
                                    if (mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content: Text('تم حذف الامتحان'),
                                            backgroundColor:
                                                AppTheme.greenSuccess),
                                      );
                                    }
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(text,
              style: TextStyle(
                  fontSize: 11, color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
