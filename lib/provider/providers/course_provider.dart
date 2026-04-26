import 'dart:io';
import 'package:flutter/material.dart';
import '../models/course_model.dart';
import '../services/supabase_service.dart';

class CourseProvider with ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();

  List<CourseModel> _courses = [];
  CourseModel? _currentCourse;
  bool _isLoading = false;
  String? _error;
  final double _uploadProgress = 0;

  List<CourseModel> get courses => _courses;
  CourseModel? get currentCourse => _currentCourse;
  bool get isLoading => _isLoading;
  String? get error => _error;
  double get uploadProgress => _uploadProgress;

  Future<void> loadCourses() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _courses = await _supabaseService.getCourses();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadCourseById(String courseId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentCourse = await _supabaseService.getCourseById(courseId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<CourseModel?> createCourse({
    required String title,
    required String description,
    required double price,
    required String level,
    required String category,
    File? imageFile,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final course = await _supabaseService.createCourse(
        title: title,
        description: description,
        price: price,
        level: level,
        category: category,
        imageFile: imageFile,
      );
      _courses.insert(0, course);
      _isLoading = false;
      notifyListeners();
      return course;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<bool> updateCourse({
    required String courseId,
    String? title,
    String? description,
    double? price,
    String? level,
    String? category,
    File? imageFile,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedCourse = await _supabaseService.updateCourse(
        courseId: courseId,
        title: title,
        description: description,
        price: price,
        level: level,
        category: category,
        imageFile: imageFile,
      );

      final index = _courses.indexWhere((c) => c.id == courseId);
      if (index != -1) {
        _courses[index] = updatedCourse;
      }
      if (_currentCourse?.id == courseId) {
        _currentCourse = updatedCourse;
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

  Future<bool> deleteCourse(String courseId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _supabaseService.deleteCourse(courseId);
      _courses.removeWhere((c) => c.id == courseId);
      if (_currentCourse?.id == courseId) {
        _currentCourse = null;
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

  Future<bool> publishCourse(String courseId, bool publish) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _supabaseService.publishCourse(courseId, publish);
      final index = _courses.indexWhere((c) => c.id == courseId);
      if (index != -1) {
        _courses[index] = _courses[index].copyWith(
          status: publish ? 'PUBLISHED' : 'DRAFT',
        );
      }
      if (_currentCourse?.id == courseId) {
        _currentCourse = _currentCourse!.copyWith(
          status: publish ? 'PUBLISHED' : 'DRAFT',
        );
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
