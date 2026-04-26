import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../config/app_theme.dart';
import '../../../config/constants.dart';
import '../../../models/question_model.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/loading_widget.dart';
import '../../../widgets/confirmation_dialog.dart';

class QuestionsScreen extends StatefulWidget {
  final String courseId;
  final String examId;

  const QuestionsScreen(
      {super.key, required this.courseId, required this.examId});

  @override
  State<QuestionsScreen> createState() => _QuestionsScreenState();
}

class _QuestionsScreenState extends State<QuestionsScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;
  List<QuestionModel> _questions = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final response = await _supabase
          .from('questions')
          .select('*, answers(*)')
          .eq('exam_id', widget.examId)
          .order('order', ascending: true);
      setState(() {
        _questions = response
            .map<QuestionModel>((json) => QuestionModel.fromJson(json))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'فشل في جلب الأسئلة';
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteQuestion(String questionId) async {
    await _supabase.from('answers').delete().eq('question_id', questionId);
    await _supabase.from('questions').delete().eq('id', questionId);
    _loadQuestions();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: const CustomAppBar(title: 'إدارة الأسئلة'),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            await context.push(
                '/courses/${widget.courseId}/exams/${widget.examId}/questions/new');
            _loadQuestions();
          },
          backgroundColor: AppTheme.primaryDarkBlue,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add),
          label: const Text('إضافة سؤال',
              style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        body: _isLoading
            ? const LoadingWidget(message: 'جاري تحميل الأسئلة...')
            : _error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline,
                            size: 60, color: AppTheme.redDanger),
                        const SizedBox(height: 16),
                        Text(_error!,
                            style: const TextStyle(color: AppTheme.redDanger)),
                        const SizedBox(height: 16),
                        ElevatedButton(
                            onPressed: _loadQuestions,
                            child: const Text('إعادة المحاولة')),
                      ],
                    ),
                  )
                : _questions.isEmpty
                    ? EmptyState(
                        title: 'لا توجد أسئلة',
                        message: 'ابدأ بإضافة أسئلة للامتحان',
                        icon: Icons.help_outline,
                        buttonText: 'إضافة سؤال جديد',
                        onButtonPressed: () async {
                          await context.push(
                              '/courses/${widget.courseId}/exams/${widget.examId}/questions/new');
                          _loadQuestions();
                        },
                      )
                    : ReorderableListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _questions.length,
                        onReorder: (oldIndex, newIndex) {
                          setState(() {
                            if (newIndex > oldIndex) newIndex--;
                            final item = _questions.removeAt(oldIndex);
                            _questions.insert(newIndex, item);
                          });
                        },
                        proxyDecorator: (child, index, animation) {
                          return Material(
                            elevation: 4,
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.white,
                            child: child,
                          );
                        },
                        itemBuilder: (context, index) {
                          final question = _questions[index];
                          return _buildQuestionItem(question, index);
                        },
                      ),
      ),
    );
  }

  Widget _buildQuestionItem(QuestionModel question, int index) {
    return Container(
      key: ValueKey(question.id),
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryDarkBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryDarkBlue),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    question.text,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryDarkBlue),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getTypeColor(question.type).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(question.type,
                      style: TextStyle(
                          fontSize: 10,
                          color: _getTypeColor(question.type),
                          fontWeight: FontWeight.w600)),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.edit_outlined,
                      size: 20, color: AppTheme.primaryDarkBlue),
                  onPressed: () async {
                    await context.push(
                        '/courses/${widget.courseId}/exams/${widget.examId}/questions/${question.id}/edit');
                    _loadQuestions();
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      size: 20, color: AppTheme.redDanger),
                  onPressed: () async {
                    final confirm = await ConfirmationDialog.show(
                      context,
                      title: 'حذف السؤال',
                      message: 'هل أنت متأكد من حذف هذا السؤال؟',
                      isDanger: true,
                      confirmText: 'حذف',
                    );
                    if (confirm == true) {
                      await _deleteQuestion(question.id);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('تم حذف السؤال'),
                              backgroundColor: AppTheme.greenSuccess),
                        );
                      }
                    }
                  },
                ),
                const Icon(Icons.drag_handle, color: AppTheme.darkGrayText),
              ],
            ),
            // Answers preview
            if (question.answers.isNotEmpty) ...[
              const SizedBox(height: 12),
              ...question.answers.map((answer) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      Icon(
                        answer.isCorrect
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        size: 18,
                        color: answer.isCorrect
                            ? AppTheme.greenSuccess
                            : AppTheme.darkGrayText,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          answer.text,
                          style: TextStyle(
                            fontSize: 13,
                            color: answer.isCorrect
                                ? AppTheme.greenSuccess
                                : AppTheme.darkGrayText,
                            fontWeight: answer.isCorrect
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
            const SizedBox(height: 4),
            Text(
              '${question.points} نقطة',
              style:
                  const TextStyle(fontSize: 11, color: AppTheme.darkGrayText),
            ),
          ],
        ),
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case AppConstants.questionTypeMultipleChoice:
        return AppTheme.blueInfo;
      case AppConstants.questionTypeTrueFalse:
        return AppTheme.greenSuccess;
      default:
        return AppTheme.primaryDarkBlue;
    }
  }
}
