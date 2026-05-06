import '../models/user_model.dart';
import 'api_client.dart';

/// خدمة المصادقة باستخدام REST API
class AuthService {
  final ApiClient _client = ApiClient();

  AuthService();

  /// تسجيل الدخول
  Future<UserModel?> signIn(String email, String password, {String? requiredRole}) async {
    final response = await _client.post(
      '/api/auth/signin',
      body: {
        'email': email,
        'password': password,
        if (requiredRole != null) 'requiredRole': requiredRole,
      },
      requiresAuth: false,
    );

    if (!response.success) {
      throw Exception(response.error ?? 'بيانات الاعتماد غير صحيحة');
    }

    final data = response.dataAsMap;
    if (data == null) return null;

    final user = UserModel.fromJson(data);
    final accessToken = data['access_token'] as String?;
    if (accessToken != null) {
      ApiClient.setAuthToken(accessToken);
    }

    return user;
  }

  /// تسجيل الخروج
  Future<void> signOut() async {
    try {
      await _client.post('/api/auth/signout');
    } finally {
      ApiClient.clearAuthToken();
    }
  }

  /// جلب المستخدم الحالي
  Future<UserModel?> getCurrentUser() async {
    final response = await _client.get('/api/auth/me');

    if (!response.success) {
      return null;
    }

    return UserModel.fromJson(response.dataAsMap);
  }

  /// تحديث كلمة المرور
  Future<void> updatePassword(String oldPassword, String newPassword) async {
    final response = await _client.put(
      '/api/auth/update-password',
      body: {
        'oldPassword': oldPassword,
        'newPassword': newPassword,
      },
    );

    if (!response.success) {
      throw Exception(response.error ?? 'فشل تحديث كلمة المرور');
    }
  }

  /// إعادة تعيين كلمة المرور
  Future<void> resetPassword(String email) async {
    final response = await _client.post(
      '/api/auth/reset-password',
      body: {'email': email},
      requiresAuth: false,
    );

    if (!response.success) {
      throw Exception(response.error ?? 'فشل إرسال رابط إعادة التعيين');
    }
  }

  /// تحديث الملف الشخصي
  Future<UserModel?> updateProfile(Map<String, dynamic> profileData) async {
    final response = await _client.put(
      '/api/auth/profile',
      body: profileData,
    );

    if (!response.success) {
      throw Exception(response.error ?? 'فشل تحديث الملف الشخصي');
    }

    return UserModel.fromJson(response.dataAsMap);
  }

  /// التحقق من حالة التوكن
  bool isAuthenticated() {
    return ApiClient.authToken != null;
  }
}