/// استثناء المصادقة
/// Authentication Exception
class AuthException implements Exception {
  final String message;
  final String? code;

  AuthException(this.message, {this.code});

  @override
  String toString() => message;
}

/// معالج أخطاء المصادقة الموحد
/// Unified Authentication Error Handler
class AuthErrorHandler {
  /// تحليل الخطأ وإرجاع استثناء موحد
  static AuthException parse(dynamic error) {
    final errorString = error.toString().toLowerCase();

    // أخطاء Supabase الشائعة
    if (errorString.contains('invalid login credentials')) {
      return AuthException(
        'البريد الإلكتروني أو كلمة المرور غير صحيحة',
        code: 'INVALID_CREDENTIALS',
      );
    }

    if (errorString.contains('email not confirmed')) {
      return AuthException(
        'يرجى تأكيد بريدك الإلكتروني أولاً',
        code: 'EMAIL_NOT_CONFIRMED',
      );
    }

    if (errorString.contains('user already registered')) {
      return AuthException(
        'هذا البريد الإلكتروني مسجل بالفعل',
        code: 'EMAIL_EXISTS',
      );
    }

    if (errorString.contains('too many requests')) {
      return AuthException(
        'محاولات كثيرة. يرجى المحاولة بعد قليل',
        code: 'TOO_MANY_REQUESTS',
      );
    }

    if (errorString.contains('network') || errorString.contains('connection')) {
      return AuthException(
        'خطأ في الاتصال بالإنترنت',
        code: 'NETWORK_ERROR',
      );
    }

    if (errorString.contains('weak password') ||
        errorString.contains('password is too weak')) {
      return AuthException(
        'كلمة المرور ضعيفة جداً',
        code: 'WEAK_PASSWORD',
      );
    }

    if (errorString.contains('account locked') ||
        errorString.contains('تم قفل الحساب')) {
      return AuthException(
        'تم قفل الحساب مؤقتاً بسبب محاولات فاشلة متعددة',
        code: 'ACCOUNT_LOCKED',
      );
    }

    if (errorString.contains('unauthorized') ||
        errorString.contains('access denied')) {
      return AuthException(
        'ليس لديك صلاحية الوصول',
        code: 'UNAUTHORIZED',
      );
    }

    if (errorString.contains('session expired') ||
        errorString.contains('token expired')) {
      return AuthException(
        'انتهت صلاحية الجلسة. يرجى تسجيل الدخول مرة أخرى',
        code: 'SESSION_EXPIRED',
      );
    }

    // أخطاء مخصصة
    if (error is AuthException) {
      return error;
    }

    // خطأ عام
    return AuthException(
      'حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى',
      code: 'UNKNOWN_ERROR',
    );
  }

  /// الحصول على رسالة محلية حسب الكود
  static String getLocalizedMessage(String code) {
    switch (code) {
      case 'INVALID_CREDENTIALS':
        return 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
      case 'EMAIL_NOT_CONFIRMED':
        return 'يرجى تأكيد بريدك الإلكتروني أولاً';
      case 'EMAIL_EXISTS':
        return 'هذا البريد الإلكتروني مسجل بالفعل';
      case 'TOO_MANY_REQUESTS':
        return 'محاولات كثيرة. يرجى المحاولة بعد قليل';
      case 'NETWORK_ERROR':
        return 'خطأ في الاتصال بالإنترنت';
      case 'WEAK_PASSWORD':
        return 'كلمة المرور ضعيفة جداً';
      case 'ACCOUNT_LOCKED':
        return 'تم قفل الحساب مؤقتاً';
      case 'UNAUTHORIZED':
        return 'ليس لديك صلاحية الوصول';
      case 'SESSION_EXPIRED':
        return 'انتهت صلاحية الجلسة';
      default:
        return 'حدث خطأ غير متوقع';
    }
  }

  /// التحقق من نوع الخطأ
  static bool isNetworkError(dynamic error) {
    return error is AuthException && error.code == 'NETWORK_ERROR';
  }

  static bool isAuthError(dynamic error) {
    return error is AuthException &&
        ['INVALID_CREDENTIALS', 'EMAIL_NOT_CONFIRMED', 'UNAUTHORIZED']
            .contains(error.code);
  }

  static bool isAccountLocked(dynamic error) {
    return error is AuthException && error.code == 'ACCOUNT_LOCKED';
  }
}
