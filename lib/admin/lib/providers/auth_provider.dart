import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:wasla_provider/shared/services/api_client.dart';
import 'package:wasla_provider/shared/services/auth_service.dart';
import '../models/user_model.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider with ChangeNotifier {
  final AuthService _authService;
  AuthStatus _status = AuthStatus.unknown;
  UserModel? _user;
  String? _errorMessage;

  AuthProvider() : _authService = AuthService() {
    checkAuth();
  }

  AuthStatus get status => _status;
  UserModel? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isLoading => _status == AuthStatus.unknown;

  Future<void> checkAuth() async {
    try {
      final result = await _authService.getCurrentUser();
      if (result != null) {
        _user = result;
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
      final result = await _authService.signIn(email, password, requiredRole: 'ADMIN');
      if (result != null) {
        _user = result;
        _status = AuthStatus.authenticated;
        notifyListeners();
        return true;
      }
      _errorMessage = 'بيانات الاعتماد غير صحيحة';
      _user = null;
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
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
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<bool> updatePassword(String oldPassword, String newPassword) async {
    try {
      await _authService.updatePassword(oldPassword, newPassword);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
