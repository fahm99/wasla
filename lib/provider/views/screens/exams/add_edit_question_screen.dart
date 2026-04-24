import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../config/app_theme.dart';
import '../../../config/constants.dart';
import '../../../widgets/custom_app_bar.dart';

class AddEditQuestionScreen extends StatefulWidget {
  final String examId;
  final String? questionId;

  const AddEditQuestionScreen(
      {super.key, required this.examId, this.questionId});

  @override
  State<AddEditQuestionScreen> createState() => _AddEditQuestionScreenState();
}

class _AddEditQuestionScreenState extends State<AddEditQuestionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _textController = TextEditingController();
  final _pointsController = TextEditingController();
  final _answerControllers = <TextEditingController>[];
  final _correctAnswers = <bool>[];

  final SupabaseClient _supabase = Supabase.instance.client;
  String _questionType = AppConstants.questionTypeMultipleChoice;
  bool _isSubmitting = false;
  int _existingQuestionsCount = 0;

  bool get _isEditing => widget.questionId != null;

  @override
  void initState() {
    super.initState();
    // Initialize with 4 answers for multiple choice
    if (!_isEditing) {
      _addAnswerField();
      _addAnswerField();
      _addAnswerField();
      _addAnswerField();
      _correctAnswers.add(true); // First answer is correct by default
      _correctAnswers.add(false);
      _correctAnswers.add(false);
      _correctAnswers.add(false);
    } else {
      _loadQuestionData();
    }
    _loadQuestionCount();
  }

  Future<void> _loadQuestionCount() async {
    try {
      final response = await _supabase
          .from('questions')
          .select('id')
          .eq('exam_id', widget.examId);
      setState(() => _existingQuestionsCount = response.length);
    } catch (_) {}
  }

  Future<void> _loadQuestionData() async {
    try {
      final response = await _supabase
          .from('questions')
          .select('*, answers(*)')
          .eq('id', widget.questionId!)
          .single();

      setState(() {
        _questionType =
            response['type'] ?? AppConstants.questionTypeMultipleChoice;
        _textController.text = response['text'] ?? '';
        _pointsController.text = (response['points'] ?? 1).toString();

        final answers = response['answers'] as List?;
        _answerControllers.clear();
        _correctAnswers.clear();
        if (answers != null) {
          for (final a in answers) {
            _answerControllers
                .add(TextEditingController(text: a['text'] ?? ''));
            _correctAnswers.add(a['is_correct'] ?? false);
          }
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل في تحميل السؤال: $e')),
        );
      }
    }
  }

  void _addAnswerField() {
    setState(() {
      _answerControllers.add(TextEditingController());
      _correctAnswers.add(false);
    });
  }

  void _removeAnswerField(int index) {
    setState(() {
      _answerControllers[index].dispose();
      _answerControllers.removeAt(index);
      _correctAnswers.removeAt(index);
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _pointsController.dispose();
    for (final c in _answerControllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // Validate answers
    final validAnswers = <Map<String, dynamic>>[];
    for (int i = 0; i < _answerControllers.length; i++) {
      final text = _answerControllers[i].text.trim();
      if (text.isNotEmpty) {
        validAnswers.add({
          'text': text,
          'is_correct': _correctAnswers[i],
        });
      }
    }

    if (_questionType == AppConstants.questionTypeMultipleChoice &&
        validAnswers.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('يجب إضافة إجابتين على الأقل'),
            backgroundColor: AppTheme.redDanger),
      );
      return;
    }

    if (!validAnswers.any((a) => a['is_correct'] == true)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('يجب تحديد إجابة صحيحة واحدة على الأقل'),
            backgroundColor: AppTheme.redDanger),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      if (_isEditing) {
        // Update question
        await _supabase.from('questions').update({
          'text': _textController.text.trim(),
          'type': _questionType,
          'points': int.parse(_pointsController.text.trim()),
        }).eq('id', widget.questionId!);

        // Delete old answers and create new ones
        await _supabase
            .from('answers')
            .delete()
            .eq('question_id', widget.questionId!);
        for (final answer in validAnswers) {
          await _supabase.from('answers').insert({
            'text': answer['text'],
            'is_correct': answer['is_correct'],
            'question_id': widget.questionId,
          });
        }
      } else {
        // Create question
        final questionResponse = await _supabase
            .from('questions')
            .insert({
              'text': _textController.text.trim(),
              'type': _questionType,
              'points': int.parse(_pointsController.text.trim()),
              'exam_id': widget.examId,
              'order': _existingQuestionsCount,
            })
            .select()
            .single();

        // Create answers
        for (final answer in validAnswers) {
          await _supabase.from('answers').insert({
            'text': answer['text'],
            'is_correct': answer['is_correct'],
            'question_id': questionResponse['id'],
          });
        }
      }

      setState(() => _isSubmitting = false);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing ? 'تم تحديث السؤال' : 'تم إنشاء السؤال'),
          backgroundColor: AppTheme.greenSuccess,
        ),
      );
      context.pop();
    } catch (e) {
      setState(() => _isSubmitting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('حدث خطأ: $e'),
              backgroundColor: AppTheme.redDanger),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: CustomAppBar(
            title: _isEditing ? 'تعديل السؤال' : 'إضافة سؤال جديد'),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Question type
                DropdownButtonFormField2<String>(
                  value: _questionType,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'نوع السؤال',
                    prefixIcon: Icon(Icons.category_outlined),
                  ),
                  items: const [
                    DropdownMenuItem(
                        value: AppConstants.questionTypeMultipleChoice,
                        child: Text('اختيار متعدد')),
                    DropdownMenuItem(
                        value: AppConstants.questionTypeTrueFalse,
                        child: Text('صح / خطأ')),
                    DropdownMenuItem(
                        value: AppConstants.questionTypeText,
                        child: Text('نصي')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _questionType = value;
                        _answerControllers.clear();
                        _correctAnswers.clear();
                        if (value == AppConstants.questionTypeTrueFalse) {
                          _answerControllers.addAll([
                            TextEditingController(text: 'صح'),
                            TextEditingController(text: 'خطأ')
                          ]);
                          _correctAnswers.addAll([true, false]);
                        } else if (value == AppConstants.questionTypeText) {
                          _answerControllers.add(TextEditingController());
                          _correctAnswers.add(true);
                        } else {
                          for (int i = 0; i < 4; i++) {
                            _answerControllers.add(TextEditingController());
                            _correctAnswers.add(i == 0);
                          }
                        }
                      });
                    }
                  },
                  dropdownStyleData: DropdownStyleData(
                    decoration:
                        BoxDecoration(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                // Question text
                TextFormField(
                  controller: _textController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'نص السؤال',
                    prefixIcon: Icon(Icons.help_outline),
                    alignLabelWithHint: true,
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'نص السؤال مطلوب'
                      : null,
                ),
                const SizedBox(height: 16),
                // Points
                TextFormField(
                  controller: _pointsController,
                  keyboardType: TextInputType.number,
                  textDirection: TextDirection.ltr,
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(
                      labelText: 'عدد النقاط',
                      hintText: '1',
                      hintTextDirection: TextDirection.ltr),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'عدد النقاط مطلوب';
                    }
                    if (int.tryParse(value.trim()) == null ||
                        int.parse(value.trim()) <= 0) return 'القيمة غير صحيحة';
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                // Answers section
                if (_questionType != AppConstants.questionTypeText) ...[
                  const Text(
                    'الإجابات',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryDarkBlue),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'حدد الإجابة الصحيحة بالنقر على الدائرة',
                    style:
                        TextStyle(fontSize: 12, color: AppTheme.darkGrayText),
                  ),
                  const SizedBox(height: 12),
                  ...List.generate(_answerControllers.length, (index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => setState(() {
                              for (int i = 0; i < _correctAnswers.length; i++) {
                                _correctAnswers[i] = i == index;
                              }
                            }),
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _correctAnswers[index]
                                    ? AppTheme.greenSuccess
                                    : Colors.transparent,
                                border: Border.all(
                                  color: _correctAnswers[index]
                                      ? AppTheme.greenSuccess
                                      : AppTheme.mediumGray,
                                  width: 2,
                                ),
                              ),
                              child: _correctAnswers[index]
                                  ? const Icon(Icons.check,
                                      color: Colors.white, size: 18)
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _answerControllers[index],
                              decoration: InputDecoration(
                                hintText: 'الإجابة ${index + 1}',
                                hintStyle: TextStyle(
                                    color:
                                        AppTheme.darkGrayText.withOpacity(0.5)),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 10),
                              ),
                            ),
                          ),
                          if (_answerControllers.length > 2 &&
                              _questionType !=
                                  AppConstants.questionTypeTrueFalse)
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline,
                                  color: AppTheme.redDanger, size: 22),
                              onPressed: () => _removeAnswerField(index),
                            ),
                        ],
                      ),
                    );
                  }),
                  if (_questionType ==
                      AppConstants.questionTypeMultipleChoice) ...[
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: _addAnswerField,
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('إضافة إجابة أخرى'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.primaryDarkBlue,
                        side: const BorderSide(color: AppTheme.primaryDarkBlue),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                ],
                // Submit
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryDarkBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : Text(_isEditing ? 'حفظ التعديلات' : 'إضافة السؤال',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
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
