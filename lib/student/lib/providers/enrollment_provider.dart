import 'package:flutter/foundation.dart';
import '../models/enrollment_model.dart';
import '../services/supabase_service.dart';

class EnrollmentProvider with ChangeNotifier {
  List<EnrollmentModel> _enrollments = [];
  EnrollmentModel? _currentEnrollment;
  bool _isLoading = false;
  String? _error;

  List<EnrollmentModel> get enrollments => _enrollments;
  EnrollmentModel? get currentEnrollment => _currentEnrollment;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<bool> enrollInCourse(String courseId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await SupabaseService.enrollInCourse(courseId);
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _parseError(e.toString());
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMyEnrollments() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _enrollments = await SupabaseService.getMyEnrollments();
      _error = null;
    } catch (e) {
      _error = 'خطأ في تحميل التسجيلات';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadEnrollment(String courseId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentEnrollment = await SupabaseService.getEnrollment(courseId);
      _error = null;
    } catch (e) {
      _currentEnrollment = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  String _parseError(String error) {
    if (error.contains('already enrolled') || error.contains('duplicate')) {
      return 'أنت مسجل في هذه الدورة بالفعل';
    }
    if (error.contains('not found')) {
      return 'الدورة غير موجودة';
    }
    return 'خطأ في التسجيل في الدورة';
  }
}
