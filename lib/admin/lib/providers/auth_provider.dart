import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;
import 'package:wasla_provider/shared/services/unified_auth_service.dart';
import 'package:wasla_provider/shared/utils/auth_error_handler.dart'
    hide AuthException;
import '../models/user_model.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider with ChangeNotifier {
  final UnifiedAuthService _authService;
  AuthStatus _status = AuthStatus.unknown;
  UserModel? _user;
  String? _errorMessage;
  late final StreamSubscription<AuthState> _authSubscription;

  AuthProvider(SupabaseClient supabaseClient)
      : _authService = UnifiedAuthService(supabaseClient) {
    _authSubscription = _authService.authStateChanges.listen((_) {
      checkAuth();
    });
    checkAuth();
  }

  AuthStatus get status => _status;
  UserModel? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isLoading => _status == AuthStatus.unknown;

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }

  Future<void> checkAuth() async {
    try {
      final result = await _authService.getCurrentUser(requiredRole: AuthRoles.admin);
      if (result != null) {
        final profile = result['profile'];
        _user = UserModel.fromJson(profile);
        _status = AuthStatus.authenticated;
      } else {
        _user = null;
        _status = AuthStatus.unauthenticated;
      }
    } catch (_) {
      _user = null;
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _errorMessage = null;
    _status = AuthStatus.unknown;
    notifyListeners();

    try {
      final result = await _authService.signIn(
        email: email,
        password: password,
        requiredRole: AuthRoles.admin,
      );

      final profile = result['profile'];
      _user = UserModel.fromJson(profile);
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = AuthErrorHandler.parse(e).message;
      _user = null;
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _authService.signOut();
      _user = null;
      _status = AuthStatus.unauthenticated;
      notifyListeners();
    } catch (e) {
      _errorMessage = AuthErrorHandler.parse(e).message;
      notifyListeners();
    }
  }

  Future<bool> updatePassword(String newPassword) async {
    try {
      await _authService.updatePassword(newPassword);
      return true;
    } catch (e) {
      _errorMessage = AuthErrorHandler.parse(e).message;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
