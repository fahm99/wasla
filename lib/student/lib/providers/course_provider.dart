import 'package:flutter/foundation.dart';
import '../models/course_model.dart';
import '../services/supabase_service.dart';

class CourseProvider with ChangeNotifier {
  List<CourseModel> _courses = [];
  CourseModel? _currentCourse;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;
  int _currentPage = 1;
  bool _hasMore = true;

  List<CourseModel> get courses => _courses;
  CourseModel? get currentCourse => _currentCourse;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get error => _error;
  bool get hasMore => _hasMore;

  Future<void> loadPublishedCourses({
    String? search,
    String? category,
    String? level,
    double? minPrice,
    double? maxPrice,
    String? sortBy,
    bool refresh = false,
  }) async {
    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
      _courses = [];
    }

    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newCourses = await SupabaseService.getPublishedCourses(
        search: search,
        category: category,
        level: level,
        minPrice: minPrice,
        maxPrice: maxPrice,
        sortBy: sortBy,
        page: _currentPage,
      );

      if (refresh) {
        _courses = newCourses;
      } else {
        _courses.addAll(newCourses);
      }

      _hasMore = newCourses.length >= 20;
      _currentPage++;
      _error = null;
    } catch (e) {
      _error = 'خطأ في تحميل الدورات';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadCourseById(String courseId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentCourse = await SupabaseService.getCourseById(courseId);
      _error = null;
    } catch (e) {
      _error = 'خطأ في تحميل الدورة';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadEnrolledCourses() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _courses = await SupabaseService.getEnrolledCourses();
      _error = null;
    } catch (e) {
      _error = 'خطأ في تحميل الدورات المسجلة';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearCourses() {
    _courses = [];
    _currentPage = 1;
    _hasMore = true;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
