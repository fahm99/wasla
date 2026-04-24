import 'dart:io';
import 'package:flutter/material.dart';
import '../models/lesson_model.dart';
import '../services/supabase_service.dart';

class LessonProvider with ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();

  List<LessonModel> _lessons = [];
  LessonModel? _currentLesson;
  bool _isLoading = false;
  String? _error;
  double _uploadProgress = 0;

  List<LessonModel> get lessons => _lessons;
  LessonModel? get currentLesson => _currentLesson;
  bool get isLoading => _isLoading;
  String? get error => _error;
  double get uploadProgress => _uploadProgress;

  Future<void> loadLessons(String moduleId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _lessons = await _supabaseService.getLessonsByModule(moduleId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<LessonModel?> createLesson({
    required String title,
    required String type,
    required String moduleId,
    required int order,
    String? content,
    File? file,
    String? fileName,
    int? fileSize,
    String? duration,
  }) async {
    _isLoading = true;
    _error = null;
    _uploadProgress = 0;
    notifyListeners();

    try {
      final lesson = await _supabaseService.createLesson(
        title: title,
        type: type,
        moduleId: moduleId,
        order: order,
        content: content,
        file: file,
        fileName: fileName,
        fileSize: fileSize,
        duration: duration,
      );
      _lessons.add(lesson);
      _lessons.sort((a, b) => a.order.compareTo(b.order));
      _isLoading = false;
      _uploadProgress = 1.0;
      notifyListeners();
      return lesson;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<bool> updateLesson({
    required String lessonId,
    String? title,
    String? type,
    String? content,
    File? file,
    String? fileName,
    int? fileSize,
    String? duration,
    int? order,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedLesson = await _supabaseService.updateLesson(
        lessonId: lessonId,
        title: title,
        type: type,
        content: content,
        file: file,
        fileName: fileName,
        fileSize: fileSize,
        duration: duration,
        order: order,
      );

      final index = _lessons.indexWhere((l) => l.id == lessonId);
      if (index != -1) {
        _lessons[index] = updatedLesson;
        _lessons.sort((a, b) => a.order.compareTo(b.order));
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

  Future<bool> deleteLesson(String lessonId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _supabaseService.deleteLesson(lessonId);
      _lessons.removeWhere((l) => l.id == lessonId);
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
