import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/supabase_service.dart';

class AuthProvider with ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    checkAuth();
  }

  Future<void> checkAuth() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await SupabaseService.getCurrentUser();
      _error = null;
    } catch (e) {
      _user = null;
      _error = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
    String? phone,
    String? gender,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await SupabaseService.signUp(
        name: name,
        email: email,
        password: password,
        phone: phone,
        gender: gender,
      );
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

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await SupabaseService.signIn(email: email, password: password);
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

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      await SupabaseService.signOut();
      _user = null;
      _error = null;
    } catch (e) {
      _error = _parseError(e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> resetPassword(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await SupabaseService.resetPassword(email);
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

  Future<bool> updateProfile({
    required String name,
    required String email,
    String? phone,
    String? bio,
    String? gender,
    String? avatar,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await SupabaseService.updateProfile(
        name: name,
        email: email,
        phone: phone,
        bio: bio,
        gender: gender,
        avatar: avatar,
      );
      _user = _user?.copyWith(
        name: name,
        email: email,
        phone: phone,
        bio: bio,
        gender: gender,
        avatar: avatar,
      );
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

  void clearError() {
    _error = null;
    notifyListeners();
  }

  String _parseError(String error) {
    if (error.contains('Invalid login credentials')) {
      return 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
    }
    if (error.contains('User already registered')) {
      return 'هذا البريد الإلكتروني مسجل بالفعل';
    }
    if (error.contains('Email not confirmed')) {
      return 'يرجى تأكيد البريد الإلكتروني';
    }
    if (error.contains('Network')) {
      return 'خطأ في الاتصال بالشبكة';
    }
    return 'حدث خطأ غير متوقع';
  }
}
