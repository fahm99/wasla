import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../config/app_theme.dart';
import '../../../models/exam_model.dart';
import '../../../models/question_model.dart';
import '../../../providers/exam_provider.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/loading_widget.dart';

class ExamTakeScreen extends StatefulWidget {
  final String examId;

  const ExamTakeScreen({super.key, required this.examId});

  @override
  State<ExamTakeScreen> createState() => _ExamTakeScreenState();
}

class _ExamTakeScreenState extends State<ExamTakeScreen> {
  late PageController _pageController;
  late Timer _timer;
  int _remainingSeconds = 0;
  final Map<String, dynamic> _answers = {};
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loadExam();
  }

  Future<void> _loadExam() async {
    await context.read<ExamProvider>().loadExamById(widget.examId);
    final exam = context.read<ExamProvider>().currentExam;
    if (exam != null && mounted) {
      setState(() {
        _remainingSeconds = exam.duration * 60;
      });
      _startTimer();
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _remainingSeconds--;
      });
      if (_remainingSeconds <= 0) {
        timer.cancel();
        _submitExam();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  Future<void> _submitExam() async {
    setState(() => _isSubmitting = true);
    _timer.cancel();

    final exam = context.read<ExamProvider>().currentExam;
    if (exam == null) return;

    final timeSpent = exam.duration * 60 - _remainingSeconds;
    final attemptId = await context.read<ExamProvider>().submitExam(
          examId: widget.examId,
          studentAnswers: _answers,
          timeSpent: timeSpent,
        );

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (attemptId != null) {
        context.go('/exams/${widget.examId}/result/$attemptId');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('خطأ في إرسال الإجابات'),
            backgroundColor: AppTheme.dangerRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExamProvider>();
    final exam = provider.currentExam;

    if (provider.isLoading) {
      return const Scaffold(
        appBar: CustomAppBar(title: 'الاختبار', showBack: true),
        body: LoadingWidget(message: 'جاري تحميل الاختبار...'),
      );
    }

    if (exam == null) {
      return const Scaffold(
        appBar: CustomAppBar(title: 'الاختبار', showBack: true),
        body: Center(child: Text('الاختبار غير موجود')),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          _showConfirmSubmitDialog();
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.lightBg,
        appBar: AppBar(
          backgroundColor: AppTheme.primaryBlue,
          foregroundColor: AppTheme.white,
          elevation: 0,
          title: Text(
            exam.title,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.white,
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.close, color: AppTheme.white),
            onPressed: _showConfirmSubmitDialog,
          ),
          actions: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: _remainingSeconds < 60
                    ? AppTheme.dangerRed
                    : Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _formatTime(_remainingSeconds),
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.white,
                ),
              ),
            ),
          ],
        ),
        body: exam.questions.isEmpty
            ? const Center(child: Text('لا توجد أسئلة'))
            : Column(
                children: [
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: exam.questions.length,
                      itemBuilder: (context, index) {
                        return _buildQuestionPage(exam.questions[index], index,
                            exam.questions.length);
                      },
                    ),
                  ),
                  _buildBottomBar(exam),
                ],
              ),
      ),
    );
  }

  Widget _buildQuestionPage(QuestionModel question, int index, int total) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'سؤال ${index + 1} من $total',
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryBlue,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${question.points} نقطة',
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12,
                    color: AppTheme.greyText,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (question.type == 'true_false')
            _buildTrueFalseQuestion(question)
          else
            _buildMultipleChoiceQuestion(question),
        ],
      ),
    );
  }

  Widget _buildMultipleChoiceQuestion(QuestionModel question) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question.text,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppTheme.darkText,
            height: 1.5,
          ),
        ),
        if (question.imageUrl != null) ...[
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              question.imageUrl!,
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          ),
        ],
        const SizedBox(height: 16),
        ...question.answers.map((answer) {
          final isSelected = _answers[question.id] == answer.id;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _answers[question.id] = answer.id;
                });
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primaryBlue : AppTheme.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color:
                        isSelected ? AppTheme.primaryBlue : AppTheme.lightGrey,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color:
                              isSelected ? AppTheme.white : AppTheme.greyText,
                          width: 2,
                        ),
                      ),
                      child: isSelected
                          ? const Icon(Icons.circle,
                              size: 12, color: AppTheme.white)
                          : null,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        answer.text,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color:
                              isSelected ? AppTheme.white : AppTheme.darkText,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildTrueFalseQuestion(QuestionModel question) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question.text,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppTheme.darkText,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _answers[question.id] = 'true';
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: _answers[question.id] == 'true'
                        ? AppTheme.successGreen
                        : AppTheme.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _answers[question.id] == 'true'
                          ? AppTheme.successGreen
                          : AppTheme.lightGrey,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 32,
                        color: _answers[question.id] == 'true'
                            ? AppTheme.white
                            : AppTheme.successGreen,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'صح',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: _answers[question.id] == 'true'
                              ? AppTheme.white
                              : AppTheme.darkText,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _answers[question.id] = 'false';
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: _answers[question.id] == 'false'
                        ? AppTheme.dangerRed
                        : AppTheme.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _answers[question.id] == 'false'
                          ? AppTheme.dangerRed
                          : AppTheme.lightGrey,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.cancel,
                        size: 32,
                        color: _answers[question.id] == 'false'
                            ? AppTheme.white
                            : AppTheme.dangerRed,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'خطأ',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: _answers[question.id] == 'false'
                              ? AppTheme.white
                              : AppTheme.darkText,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBottomBar(ExamModel exam) {
    final currentPage =
        _pageController.hasClients ? _pageController.page?.round() ?? 0 : 0;
    final totalPages = exam.questions.length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'السؤال ${currentPage + 1} من $totalPages',
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13,
                    color: AppTheme.greyText,
                  ),
                ),
                Text(
                  'أجبت على ${_answers.length} من $totalPages',
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13,
                    color: AppTheme.primaryBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: currentPage > 0
                        ? () => _pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            )
                        : null,
                    child: const Text('السابق'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: currentPage < totalPages - 1
                      ? ElevatedButton(
                          onPressed: () => _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          ),
                          child: const Text('التالي'),
                        )
                      : ElevatedButton(
                          onPressed:
                              _isSubmitting ? null : _showConfirmSubmitDialog,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.successGreen,
                          ),
                          child: _isSubmitting
                              ? const CircularProgressIndicator(
                                  color: AppTheme.white, strokeWidth: 2)
                              : const Text('إرسال الإجابات'),
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showConfirmSubmitDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'تأكيد الإرسال',
          style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700),
        ),
        content: Text(
          'هل أنت متأكد من إرسال الإجابات؟\nأجبت على ${_answers.length} سؤال من ${context.read<ExamProvider>().currentExam?.questions.length ?? 0}',
          style: const TextStyle(fontFamily: 'Cairo', color: AppTheme.greyText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('العودة للاختبار'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _submitExam();
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.successGreen),
            child: const Text('تأكيد الإرسال'),
          ),
        ],
      ),
    );
  }
}
