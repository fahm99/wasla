import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wasla_provider/shared/auth_module.dart';
import '../models/user_model.dart';

class AuthProvider with ChangeNotifier {
  final UnifiedAuthService _authModule = UnifiedAuthService(Supabase.instance.client);

  UserModel? _user;
  bool _isLoading = false;
  String? _error;
  bool _requiresEmailConfirmation = false;
  String? _pendingEmail;
  late final StreamSubscription<AuthState> _authSubscription;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;
  bool get requiresEmailConfirmation => _requiresEmailConfirmation;
  String? get pendingEmail => _pendingEmail;

  AuthProvider() {
    _authSubscription = _authModule.authStateChanges.listen((_) {
      checkAuth();
    });
    checkAuth();
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }

  Future<void> checkAuth() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _authModule.getCurrentUser(requiredRole: AuthRoles.student);
      if (result != null && result['profile'] != null) {
        _user = UserModel.fromJson(result['profile']);
        _requiresEmailConfirmation = false;
      } else {
        _user = null;
      }
      _error = null;
    } catch (_) {
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
      final result = await _authModule.signUp(
        name: name,
        email: email,
        password: password,
        role: AuthRoles.student,
        phone: phone,
        gender: gender,
      );

      _user = null;
      _pendingEmail = (result['email'] ?? email).toString();
      _requiresEmailConfirmation = result['requires_email_confirmation'] == true;
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
      final result = await _authModule.signIn(
        email: email,
        password: password,
        requiredRole: AuthRoles.student,
      );
      _user = UserModel.fromJson(result['profile']);
      _requiresEmailConfirmation = false;
      _pendingEmail = null;
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
      await _authModule.signOut();
      _user = null;
      _error = null;
      _requiresEmailConfirmation = false;
      _pendingEmail = null;
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
      await _authModule.resetPassword(email);
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

  Future<bool> resendConfirmationEmail() async {
    if (_pendingEmail == null || _pendingEmail!.isEmpty) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authModule.resendEmailConfirmation(_pendingEmail!);
      _error = null;
      return true;
    } catch (e) {
      _error = _parseError(e.toString());
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
    if (_user == null) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _authModule.updateProfile(
        userId: _user!.id,
        name: name,
        email: email,
        phone: phone,
        bio: bio,
        gender: gender,
        avatar: avatar,
      );

      _user = UserModel.fromJson(response);
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

  void clearPendingVerification() {
    _requiresEmailConfirmation = false;
    _pendingEmail = null;
    notifyListeners();
  }

  String _parseError(String error) {
    if (error.contains('INVALID_CREDENTIALS')) {
      return 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
    }
    if (error.contains('EMAIL_EXISTS')) {
      return 'هذا البريد الإلكتروني مسجل بالفعل';
    }
    if (error.contains('EMAIL_NOT_CONFIRMED')) {
      return 'يرجى تأكيد البريد الإلكتروني أولاً';
    }
    if (error.contains('ACCOUNT_PENDING')) {
      return 'حسابك بانتظار التفعيل';
    }
    if (error.contains('UNAUTHORIZED')) {
      return 'هذا الحساب غير مخصص لتطبيق الطالب';
    }
    if (error.contains('NETWORK_ERROR')) {
      return 'خطأ في الاتصال بالشبكة';
    }
    return 'حدث خطأ غير متوقع';
  }
}
