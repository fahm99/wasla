import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../config/app_theme.dart';
import '../../../providers/exam_provider.dart';
import '../../../widgets/custom_app_bar.dart';

class AddEditExamScreen extends StatefulWidget {
  final String courseId;
  final String? examId;

  const AddEditExamScreen({super.key, required this.courseId, this.examId});

  @override
  State<AddEditExamScreen> createState() => _AddEditExamScreenState();
}

class _AddEditExamScreenState extends State<AddEditExamScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _passingScoreController = TextEditingController();
  final _durationController = TextEditingController();
  bool _isSubmitting = false;

  bool get _isEditing => widget.examId != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _loadExamData();
    }
  }

  void _loadExamData() {
    final provider = context.read<ExamProvider>();
    final exam = provider.exams.where((e) => e.id == widget.examId).firstOrNull;
    if (exam != null) {
      _titleController.text = exam.title;
      _descriptionController.text = exam.description;
      _passingScoreController.text = exam.passingScore.toString();
      _durationController.text = exam.duration ?? '';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _passingScoreController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    final provider = context.read<ExamProvider>();
    bool success;

    if (_isEditing) {
      success = await provider.updateExam(
        examId: widget.examId!,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        passingScore: int.parse(_passingScoreController.text.trim()),
        duration: _durationController.text.trim().isNotEmpty ? _durationController.text.trim() : null,
      );
    } else {
      final exam = await provider.createExam(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        passingScore: int.parse(_passingScoreController.text.trim()),
        courseId: widget.courseId,
        duration: _durationController.text.trim().isNotEmpty ? _durationController.text.trim() : null,
      );
      success = exam != null;
    }

    setState(() => _isSubmitting = false);
    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing ? 'تم تحديث الامتحان' : 'تم إنشاء الامتحان'),
          backgroundColor: AppTheme.greenSuccess,
        ),
      );
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.error ?? 'حدث خطأ'), backgroundColor: AppTheme.redDanger),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: CustomAppBar(title: _isEditing ? 'تعديل الامتحان' : 'إضافة امتحان جديد'),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'عنوان الامتحان', prefixIcon: Icon(Icons.quiz_outlined)),
                  validator: (value) => value == null || value.trim().isEmpty ? 'عنوان الامتحان مطلوب' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'وصف الامتحان', prefixIcon: Icon(Icons.description_outlined), alignLabelWithHint: true),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _passingScoreController,
                        keyboardType: TextInputType.number,
                        textDirection: TextDirection.ltr,
                        textAlign: TextAlign.center,
                        decoration: const InputDecoration(labelText: 'درجة النجاح (%)', hintText: '60', hintTextDirection: TextDirection.ltr),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return 'درجة النجاح مطلوبة';
                          final score = int.tryParse(value.trim());
                          if (score == null || score < 0 || score > 100) return 'القيمة يجب أن تكون بين 0 و 100';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _durationController,
                        keyboardType: TextInputType.number,
                        textDirection: TextDirection.ltr,
                        textAlign: TextAlign.center,
                        decoration: const InputDecoration(labelText: 'المدة (دقائق)', hintText: '30', hintTextDirection: TextDirection.ltr),
                      ),
                    ),
                  ],
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
                        : Text(_isEditing ? 'حفظ التعديلات' : 'إنشاء الامتحان', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
