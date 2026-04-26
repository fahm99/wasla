import 'dart:async';

import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _user;
  bool _isLoading = false;
  String? _error;
  bool _isAuthenticated = false;
  bool _requiresEmailConfirmation = false;
  String? _pendingEmail;
  late final StreamSubscription _authSubscription;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _isAuthenticated;
  bool get requiresEmailConfirmation => _requiresEmailConfirmation;
  String? get pendingEmail => _pendingEmail;

  AuthProvider() {
    _authSubscription = _authService.authStateChanges.listen((_) {
      _checkAuth();
    });
    _checkAuth();
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }

  Future<void> _checkAuth() async {
    final currentUser = await _authService.getCurrentUserProfile();
    _user = currentUser;
    _isAuthenticated = currentUser != null;
    if (_isAuthenticated) {
      _requiresEmailConfirmation = false;
      _pendingEmail = null;
    }
    notifyListeners();
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
    String? phone,
    String? institutionType,
    String? institutionName,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _authService.signUp(
        email: email,
        password: password,
        name: name,
        phone: phone,
        institutionType: institutionType,
        institutionName: institutionName,
      );
      _user = null;
      _isAuthenticated = false;
      _pendingEmail = (result['email'] ?? email).toString();
      _requiresEmailConfirmation = result['requires_email_confirmation'] == true;
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

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _authService.signIn(
        email: email,
        password: password,
      );
      _isAuthenticated = true;
      _requiresEmailConfirmation = false;
      _pendingEmail = null;
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

  Future<void> signOut() async {
    await _authService.signOut();
    _user = null;
    _isAuthenticated = false;
    _requiresEmailConfirmation = false;
    _pendingEmail = null;
    notifyListeners();
  }

  Future<bool> resendConfirmationEmail() async {
    if (_pendingEmail == null || _pendingEmail!.isEmpty) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.resendConfirmationEmail(_pendingEmail!);
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

  Future<bool> updateProfile({
    String? name,
    String? phone,
    String? institutionType,
    String? institutionName,
    String? bankAccount,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _authService.updateProfile(
        userId: _user!.id,
        name: name,
        phone: phone,
        institutionType: institutionType,
        institutionName: institutionName,
        bankAccount: bankAccount,
      );
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

  Future<bool> updateAvatar(dynamic imageFile) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final url = await _authService.updateAvatar(
        userId: _user!.id,
        imageFile: imageFile,
      );
      _user = _user!.copyWith(avatar: url);
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

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
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
