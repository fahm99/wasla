import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;
import 'package:gotrue/src/types/auth_exception.dart';
import '../utils/auth_error_handler.dart' hide AuthException;

class AuthRoles {
  static const String student = 'STUDENT';
  static const String provider = 'PROVIDER';
  static const String admin = 'ADMIN';
}

class AuthStatuses {
  static const String pending = 'PENDING';
  static const String active = 'ACTIVE';
  static const String suspended = 'SUSPENDED';
  static const String rejected = 'REJECTED';
}

class UnifiedAuthService {
  final SupabaseClient _client;

  UnifiedAuthService(this._client);

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
    String? requiredRole,
  }) async {
    try {
      final normalizedEmail = email.trim().toLowerCase();
      final checkResult = await _checkLoginAttempts(normalizedEmail);

      if (checkResult['is_locked'] == true) {
        throw const AuthException(
          'تم قفل الحساب مؤقتاً بسبب محاولات فاشلة متعددة. يرجى المحاولة بعد ساعة.',
          code: 'ACCOUNT_LOCKED',
        );
      }

      final response = await _client.auth.signInWithPassword(
        email: normalizedEmail,
        password: password,
      );

      if (response.user == null) {
        await _logLoginAttempt(normalizedEmail,
            success: false, reason: 'Invalid credentials');
        throw const AuthException('فشل تسجيل الدخول', code: 'INVALID_CREDENTIALS');
      }

      final profile = await _fetchProfile(response.user!.id);

      if (requiredRole != null && profile['role'] != requiredRole) {
        await _client.auth.signOut();
        await _logLoginAttempt(normalizedEmail, success: false, reason: 'Wrong role');
        throw const AuthException(
          'ليس لديك صلاحية الوصول إلى هذا التطبيق',
          code: 'UNAUTHORIZED',
        );
      }

      final status = (profile['status'] ?? '').toString().toUpperCase();
      if (status != AuthStatuses.active) {
        await _client.auth.signOut();
        await _logLoginAttempt(normalizedEmail,
            success: false, reason: 'Account not active');

        if (status == AuthStatuses.pending) {
          throw const AuthException(
            'حسابك ما زال بانتظار التفعيل أو الموافقة',
            code: 'ACCOUNT_PENDING',
          );
        }

        throw const AuthException(
          'حسابك غير مفعل. يرجى الاتصال بالدعم',
          code: 'ACCOUNT_INACTIVE',
        );
      }

      await _logLoginAttempt(normalizedEmail, success: true);
      await _createSession(response.user!.id);

      return {
        'user': response.user,
        'profile': profile,
      };
    } catch (e) {
      if (e is AuthException) {
        rethrow;
      }
      throw AuthErrorHandler.parse(e);
    }
  }

  Future<Map<String, dynamic>> signUp({
    required String name,
    required String email,
    required String password,
    required String role,
    String? phone,
    String? gender,
    String? institutionType,
    String? institutionName,
  }) async {
    try {
      if (!_isPasswordStrong(password)) {
        throw const AuthException(
          'كلمة المرور ضعيفة. يجب أن تحتوي على 8 أحرف على الأقل، حرف كبير، رقم، ورمز خاص',
          code: 'WEAK_PASSWORD',
        );
      }

      if (role == AuthRoles.admin) {
        throw const AuthException(
          'لا يمكن إنشاء حسابات المشرفين من التطبيق',
          code: 'UNAUTHORIZED',
        );
      }

      final normalizedEmail = email.trim().toLowerCase();
      final response = await _client.auth.signUp(
        email: normalizedEmail,
        password: password,
        data: {
          'name': name,
          'phone': phone,
          'gender': gender,
          'role': role,
          'institution_type': institutionType,
          'institution_name': institutionName,
        },
        emailRedirectTo: 'wasla://confirm-email',
      );

      if (response.user == null) {
        throw const AuthException('فشل إنشاء الحساب', code: 'SIGNUP_FAILED');
      }

      return {
        'user': response.user,
        'email': normalizedEmail,
        'requires_email_confirmation': response.user!.emailConfirmedAt == null,
        'email_confirmed': response.user!.emailConfirmedAt != null,
      };
    } catch (e) {
      if (e is AuthException) {
        rethrow;
      }
      throw AuthErrorHandler.parse(e);
    }
  }

  Future<void> signOut() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId != null) {
        await _endSession(userId);
      }
      await _client.auth.signOut();
    } catch (e) {
      throw AuthErrorHandler.parse(e);
    }
  }

  Future<Map<String, dynamic>?> getCurrentUser({String? requiredRole}) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return null;

      final profile = await _fetchProfile(user.id);
      final role = (profile['role'] ?? '').toString().toUpperCase();
      final status = (profile['status'] ?? '').toString().toUpperCase();

      if (requiredRole != null && role != requiredRole) {
        return null;
      }

      if (status != AuthStatuses.active && requiredRole != AuthRoles.admin) {
        return null;
      }

      return {
        'user': user,
        'profile': profile,
      };
    } catch (_) {
      return null;
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(
        email.trim().toLowerCase(),
        redirectTo: 'wasla://reset-password',
      );
    } catch (e) {
      throw AuthErrorHandler.parse(e);
    }
  }

  Future<void> resendEmailConfirmation(String email) async {
    try {
      await _client.auth.resend(
        type: OtpType.signup,
        email: email.trim().toLowerCase(),
        emailRedirectTo: 'wasla://confirm-email',
      );
    } catch (e) {
      throw AuthErrorHandler.parse(e);
    }
  }

  Future<void> updatePassword(String newPassword) async {
    try {
      if (!_isPasswordStrong(newPassword)) {
        throw const AuthException('كلمة المرور ضعيفة', code: 'WEAK_PASSWORD');
      }

      await _client.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      await _logSecurityEvent(
        eventType: 'PASSWORD_CHANGED',
        description: 'تم تغيير كلمة المرور',
      );
    } catch (e) {
      throw AuthErrorHandler.parse(e);
    }
  }

  Future<Map<String, dynamic>> updateProfile({
    required String userId,
    String? name,
    String? email,
    String? phone,
    String? bio,
    String? gender,
    String? avatar,
    String? institutionType,
    String? institutionName,
    String? bankAccount,
    String? bankName,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (email != null) updates['email'] = email.trim().toLowerCase();
      if (phone != null) updates['phone'] = phone;
      if (bio != null) updates['bio'] = bio;
      if (gender != null) updates['gender'] = gender;
      if (avatar != null) updates['avatar'] = avatar;
      if (institutionType != null) updates['institution_type'] = institutionType;
      if (institutionName != null) updates['institution_name'] = institutionName;
      if (bankAccount != null) updates['bank_account'] = bankAccount;
      if (bankName != null) updates['bank_name'] = bankName;
      updates['updated_at'] = DateTime.now().toIso8601String();

      final response = await _client
          .from('profiles')
          .update(updates)
          .eq('id', userId)
          .select()
          .single();

      if (email != null && email.trim().toLowerCase() != _client.auth.currentUser?.email) {
        await _client.auth.updateUser(
          UserAttributes(email: email.trim().toLowerCase()),
        );
      }

      return response;
    } catch (e) {
      throw AuthErrorHandler.parse(e);
    }
  }

  Future<Map<String, dynamic>> _fetchProfile(String userId) async {
    final profile = await _client.from('profiles').select().eq('id', userId).single();
    return Map<String, dynamic>.from(profile as Map);
  }

  bool _isPasswordStrong(String password) {
    if (password.length < 8) return false;
    if (!password.contains(RegExp(r'[A-Z]'))) return false;
    if (!password.contains(RegExp(r'[0-9]'))) return false;
    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) return false;
    return true;
  }

  Future<Map<String, dynamic>> _checkLoginAttempts(String email) async {
    try {
      final result = await _client.rpc('check_login_attempts', params: {'p_email': email});
      return Map<String, dynamic>.from(result as Map);
    } catch (_) {
      return {
        'is_locked': false,
        'failed_attempts': 0,
        'security_logging_available': false,
      };
    }
  }

  Future<void> _logLoginAttempt(
    String email, {
    required bool success,
    String? reason,
  }) async {
    try {
      await _client.rpc('log_login_attempt', params: {
        'p_email': email,
        'p_success': success,
        'p_ip_address': 'N/A',
        'p_user_agent': 'Flutter App',
        'p_failure_reason': reason,
      });
    } catch (_) {}
  }

  Future<void> _createSession(String userId) async {
    try {
      await _client.rpc('create_user_session', params: {
        'p_user_id': userId,
        'p_device_name': 'Mobile Device',
        'p_device_type': 'Mobile',
        'p_device_id': 'flutter_app',
        'p_ip_address': 'N/A',
        'p_user_agent': 'Flutter App',
      });
    } catch (_) {}
  }

  Future<void> _endSession(String userId) async {
    try {
      await _client.rpc('end_user_session', params: {
        'p_user_id': userId,
        'p_end_all': true,
      });
    } catch (_) {}
  }

  Future<void> _logSecurityEvent({
    required String eventType,
    required String description,
  }) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return;

      await _client.rpc('log_security_event', params: {
        'p_user_id': userId,
        'p_event_type': eventType,
        'p_event_description': description,
        'p_ip_address': 'N/A',
        'p_user_agent': 'Flutter App',
        'p_metadata': <String, dynamic>{},
        'p_severity': 'INFO',
      });
    } catch (_) {}
  }
}
