import 'package:flutter/material.dart';
import '../models/exam_model.dart';
import '../services/supabase_service.dart';

class ExamProvider with ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();

  List<ExamModel> _exams = [];
  ExamModel? _currentExam;
  bool _isLoading = false;
  String? _error;

  List<ExamModel> get exams => _exams;
  ExamModel? get currentExam => _currentExam;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadExams(String courseId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _exams = await _supabaseService.getExamsByCourse(courseId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<ExamModel?> createExam({
    required String title,
    required String description,
    required int passingScore,
    required String courseId,
    int duration = 30,
    int maxAttempts = 3,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final exam = await _supabaseService.createExam(
        title: title,
        description: description,
        passingScore: passingScore,
        courseId: courseId,
        duration: duration,
        maxAttempts: maxAttempts,
      );
      _exams.insert(0, exam);
      _isLoading = false;
      notifyListeners();
      return exam;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<bool> updateExam({
    required String examId,
    String? title,
    String? description,
    int? passingScore,
    int? duration,
    int? maxAttempts,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedExam = await _supabaseService.updateExam(
        examId: examId,
        title: title,
        description: description,
        passingScore: passingScore,
        duration: duration,
        maxAttempts: maxAttempts,
      );

      final index = _exams.indexWhere((e) => e.id == examId);
      if (index != -1) {
        _exams[index] = updatedExam;
      }
      if (_currentExam?.id == examId) {
        _currentExam = updatedExam;
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteExam(String examId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _supabaseService.deleteExam(examId);
      _exams.removeWhere((e) => e.id == examId);
      if (_currentExam?.id == examId) {
        _currentExam = null;
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void setError(String error) {
    _error = error;
    notifyListeners();
  }
}
