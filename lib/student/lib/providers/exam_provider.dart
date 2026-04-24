import 'package:flutter/foundation.dart';
import '../models/exam_model.dart';
import '../services/supabase_service.dart';

class ExamProvider with ChangeNotifier {
  List<ExamModel> _exams = [];
  ExamModel? _currentExam;
  Map<String, dynamic>? _examResult;
  bool _isLoading = false;
  String? _error;

  List<ExamModel> get exams => _exams;
  ExamModel? get currentExam => _currentExam;
  Map<String, dynamic>? get examResult => _examResult;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadExamsByCourse(String courseId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _exams = await SupabaseService.getExamsByCourse(courseId);
      _error = null;
    } catch (e) {
      _error = 'خطأ في تحميل الاختبارات';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadExamById(String examId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentExam = await SupabaseService.getExamById(examId);
      _error = null;
    } catch (e) {
      _error = 'خطأ في تحميل الاختبار';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> submitExam({
    required String examId,
    required Map<String, dynamic> studentAnswers,
    required int timeSpent,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final attemptId = await SupabaseService.submitExamAttempt(
        examId: examId,
        studentAnswers: studentAnswers,
        timeSpent: timeSpent,
      );
      _error = null;
      notifyListeners();
      return attemptId;
    } catch (e) {
      _error = 'خطأ في إرسال الإجابات';
      notifyListeners();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadExamResult(String attemptId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _examResult = await SupabaseService.getExamAttempt(attemptId);
      _error = null;
    } catch (e) {
      _error = 'خطأ في تحميل النتيجة';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
