import 'package:flutter/foundation.dart';
import '../models/course_model.dart';
import '../services/supabase_service.dart';

class CoursesProvider with ChangeNotifier {
  final SupabaseService _supabaseService;

  CoursesProvider(this._supabaseService);

  List<CourseModel> _courses = [];
  List<CourseModel> _filteredCourses = [];
  CourseModel? _selectedCourse;
  bool _isLoading = false;
  bool _isActionLoading = false;
  String? _errorMessage;
  String _currentFilter = '';
  String _searchQuery = '';

  List<CourseModel> get courses => _filteredCourses;
  CourseModel? get selectedCourse => _selectedCourse;
  bool get isLoading => _isLoading;
  bool get isActionLoading => _isActionLoading;
  String? get errorMessage => _errorMessage;
  String get currentFilter => _currentFilter;

  Future<void> loadCourses() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _courses = await _supabaseService.getAllCourses(
        status: _currentFilter.isEmpty ? null : _currentFilter,
      );
      _applyFilter();
    } catch (e) {
      _errorMessage = 'حدث خطأ في تحميل الكورسات';
      _courses = [];
      _filteredCourses = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setFilter(String filter) {
    _currentFilter = filter;
    loadCourses();
  }

  void searchCourses(String query) {
    _searchQuery = query;
    _applyFilter();
  }

  void _applyFilter() {
    if (_searchQuery.isEmpty) {
      _filteredCourses = List.from(_courses);
    } else {
      _filteredCourses = _courses
          .where(
              (c) => c.title.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }

  Future<CourseModel> getCourseDetail(String id) async {
    _isLoading = true;
    notifyListeners();

    try {
      _selectedCourse = await _supabaseService.getCourseById(id);
      notifyListeners();
      return _selectedCourse!;
    } catch (e) {
      _errorMessage = 'حدث خطأ في تحميل بيانات الكورس';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateCourseStatus(String id, String status) async {
    _isActionLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updated = await _supabaseService.updateCourseStatus(id, status);

      final index = _courses.indexWhere((c) => c.id == id);
      if (index != -1) {
        _courses[index] = updated;
      }
      final filteredIndex = _filteredCourses.indexWhere((c) => c.id == id);
      if (filteredIndex != -1) {
        if (_currentFilter.isEmpty || _currentFilter == status) {
          _filteredCourses[filteredIndex] = updated;
        } else {
          _filteredCourses.removeAt(filteredIndex);
        }
      }

      if (_selectedCourse?.id == id) {
        _selectedCourse = updated;
      }

      _isActionLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'حدث خطأ في تحديث حالة الكورس';
      _isActionLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
