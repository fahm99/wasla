import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/supabase_service.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider with ChangeNotifier {
  final SupabaseService _supabaseService;
  AuthStatus _status = AuthStatus.unknown;
  UserModel? _user;
  String? _errorMessage;

  AuthProvider(this._supabaseService) {
    checkAuth();
  }

  AuthStatus get status => _status;
  UserModel? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isLoading => _status == AuthStatus.unknown;

  Future<void> checkAuth() async {
    try {
      final user = await _supabaseService.getCurrentUser();
      if (user != null && user.role == 'ADMIN') {
        _user = user;
        _status = AuthStatus.authenticated;
      } else {
        _status = AuthStatus.unauthenticated;
      }
    } catch (e) {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _errorMessage = null;
    _status = AuthStatus.unknown;
    notifyListeners();

    try {
      final user = await _supabaseService.signIn(email, password);
      if (user == null) {
        _errorMessage = 'فشل تسجيل الدخول. تحقق من البيانات.';
        _status = AuthStatus.unauthenticated;
        notifyListeners();
        return false;
      }
      if (user.role != 'ADMIN') {
        await _supabaseService.signOut();
        _errorMessage = 'هذا الحساب ليس حساب مشرف. الوصول مرفوض.';
        _status = AuthStatus.unauthenticated;
        notifyListeners();
        return false;
      }
      _user = user;
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = _parseError(e);
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _supabaseService.signOut();
      _user = null;
      _status = AuthStatus.unauthenticated;
      notifyListeners();
    } catch (e) {
      _errorMessage = _parseError(e);
      notifyListeners();
    }
  }

  Future<bool> updatePassword(String newPassword) async {
    try {
      await _supabaseService.updatePassword(newPassword);
      return true;
    } catch (e) {
      _errorMessage = _parseError(e);
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  String _parseError(dynamic error) {
    if (error.toString().contains('Invalid login credentials')) {
      return 'بيانات الدخول غير صحيحة';
    }
    if (error.toString().contains('Too many requests')) {
      return 'محاولات كثيرة. حاول بعد قليل';
    }
    if (error.toString().contains('Email not confirmed')) {
      return 'البريد الإلكتروني غير مؤكد';
    }
    if (error.toString().contains('Network')) {
      return 'لا يوجد اتصال بالإنترنت';
    }
    return 'حدث خطأ غير متوقع';
  }
}
