import 'package:flutter/foundation.dart';
import '../models/course_model.dart';
import '../services/supabase_service.dart';

class SearchProvider with ChangeNotifier {
  List<CourseModel> _results = [];
  bool _isLoading = false;
  String? _error;
  String _query = '';
  String? _selectedCategory;
  String? _selectedLevel;
  double? _minPrice;
  double? _maxPrice;
  String _sortBy = 'newest';
  bool _showFilters = false;

  List<CourseModel> get results => _results;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get query => _query;
  String? get selectedCategory => _selectedCategory;
  String? get selectedLevel => _selectedLevel;
  double? get minPrice => _minPrice;
  double? get maxPrice => _maxPrice;
  String get sortBy => _sortBy;
  bool get showFilters => _showFilters;

  Future<void> search({
    String? query,
    String? category,
    String? level,
    double? minPrice,
    double? maxPrice,
    String? sortBy,
    bool refresh = true,
  }) async {
    _query = query ?? _query;
    _selectedCategory = category ?? _selectedCategory;
    _selectedLevel = level ?? _selectedLevel;
    _minPrice = minPrice ?? _minPrice;
    _maxPrice = maxPrice ?? _maxPrice;
    _sortBy = sortBy ?? _sortBy;

    if (_query.isEmpty && _selectedCategory == null && _selectedLevel == null) {
      _results = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _results = await SupabaseService.getPublishedCourses(
        search: _query.isNotEmpty ? _query : null,
        category: _selectedCategory,
        level: _selectedLevel,
        minPrice: _minPrice,
        maxPrice: _maxPrice,
        sortBy: _sortBy,
      );
      _error = null;
    } catch (e) {
      _error = 'خطأ في البحث';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearFilters() {
    _selectedCategory = null;
    _selectedLevel = null;
    _minPrice = null;
    _maxPrice = null;
    _sortBy = 'newest';
    notifyListeners();
  }

  void toggleFilters() {
    _showFilters = !_showFilters;
    notifyListeners();
  }

  void setQuery(String q) {
    _query = q;
    notifyListeners();
  }

  void clearSearch() {
    _query = '';
    _results = [];
    _selectedCategory = null;
    _selectedLevel = null;
    _minPrice = null;
    _maxPrice = null;
    _sortBy = 'newest';
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
