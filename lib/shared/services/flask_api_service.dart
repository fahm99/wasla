import '../models/user_model.dart';
import '../models/course_model.dart';
import '../models/payment_model.dart';
import '../models/notification_model.dart' as app_notif;
import '../models/stats_model.dart';
import '../models/monthly_stats_model.dart';
import 'api_client.dart';

/// خدمة API لل Flask Backend
class FlaskApiService {
  final ApiClient _client = ApiClient();

  FlaskApiService();

  // ==================== AUTH ====================

  Future<UserModel?> signIn(String email, String password) async {
    final response = await _client.post(
      '/api/auth/signin',
      body: {'email': email, 'password': password},
      requiresAuth: false,
    );

    if (!response.success) {
      throw Exception(response.error ?? 'فشل تسجيل الدخول');
    }

    final data = response.dataAsMap;
    if (data == null) return null;

    // Save token
    final accessToken = data['access_token'] as String?;
    if (accessToken != null) {
      ApiClient.setAuthToken(accessToken);
    }

    return _userFromJson(data);
  }

  Future<void> signOut() async {
    await _client.post('/api/auth/signout');
    ApiClient.clearAuthToken();
  }

  Future<UserModel?> getCurrentUser() async {
    final response = await _client.get('/api/auth/me');

    if (!response.success) {
      return null;
    }

    return _userFromJson(response.dataAsMap);
  }

  Future<bool> isAdmin() async {
    final user = await getCurrentUser();
    return user?.role == 'ADMIN';
  }

  Future<void> updatePassword(String newPassword) async {
    await _client.put(
      '/api/auth/update-password',
      body: {'newPassword': newPassword},
    );
  }

  // ==================== DASHBOARD ====================

  Future<StatsModel> getStats() async {
    final response = await _client.get('/api/admin/stats');

    if (response.success && response.dataAsMap != null) {
      return StatsModel.fromJson(response.dataAsMap!);
    }

    return StatsModel(
      activeProviders: 0,
      pendingAccounts: 0,
      suspendedAccounts: 0,
      totalStudents: 0,
      totalCourses: 0,
      totalRevenue: 0,
      totalPayments: 0,
      totalNotifications: 0,
    );
  }

  Future<List<MonthlyStatsModel>> getMonthlyStats() async {
    final response = await _client.get('/api/admin/monthly-stats');

    if (response.success && response.dataAsList != null) {
      return response.dataAsList!
          .map((e) => MonthlyStatsModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return [];
  }

  // ==================== ACCOUNTS ====================

  Future<List<UserModel>> getAllAccounts({
    String? role,
    String? status,
    String? search,
  }) async {
    final queryParams = <String, String>{};
    if (role != null && role.isNotEmpty) queryParams['role'] = role;
    if (status != null && status.isNotEmpty) queryParams['status'] = status;
    if (search != null && search.isNotEmpty) queryParams['search'] = search;

    final response = await _client.get(
      '/api/admin/accounts',
      queryParams: queryParams.isNotEmpty ? queryParams : null,
    );

    if (response.success && response.dataAsList != null) {
      return response.dataAsList!
          .map((e) => UserModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return [];
  }

  Future<UserModel> getAccountById(String id) async {
    final response = await _client.get('/api/admin/accounts/$id');

    if (response.success && response.dataAsMap != null) {
      return UserModel.fromJson(response.dataAsMap!);
    }

    throw Exception(response.error ?? 'فشل جلب الحساب');
  }

  Future<UserModel> updateAccountStatus(String id, String status) async {
    final response = await _client.put(
      '/api/admin/accounts/$id/status',
      body: {'status': status},
    );

    if (response.success && response.dataAsMap != null) {
      return UserModel.fromJson(response.dataAsMap!);
    }

    throw Exception(response.error ?? 'فشل تحديث الحالة');
  }

  Future<List<UserModel>> getPendingAccounts() async {
    return getAllAccounts(status: 'PENDING');
  }

  // ==================== COURSES ====================

  Future<List<CourseModel>> getAllCourses({
    String? status,
    String? search,
  }) async {
    final queryParams = <String, String>{};
    if (status != null && status.isNotEmpty) queryParams['status'] = status;
    if (search != null && search.isNotEmpty) queryParams['search'] = search;

    final response = await _client.get(
      '/api/courses',
      queryParams: queryParams.isNotEmpty ? queryParams : null,
    );

    if (response.success && response.dataAsList != null) {
      return response.dataAsList!
          .map((e) => CourseModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return [];
  }

  Future<CourseModel> getCourseById(String id) async {
    final response = await _client.get('/api/courses/$id');

    if (response.success && response.dataAsMap != null) {
      return CourseModel.fromJson(response.dataAsMap!);
    }

    throw Exception(response.error ?? 'فشل جلب الدورة');
  }

  Future<CourseModel> updateCourseStatus(String id, String status) async {
    final response = await _client.put(
      '/api/courses/$id/status',
      body: {'status': status},
    );

    if (response.success && response.dataAsMap != null) {
      return CourseModel.fromJson(response.dataAsMap!);
    }

    throw Exception(response.error ?? 'فشل تحديث الدورة');
  }

  Future<int> getCourseEnrollmentsCount(String courseId) async {
    final response = await _client.get('/api/courses/$courseId/enrollments');

    if (response.success && response.dataAsMap != null) {
      return response.dataAsMap!['count'] as int? ?? 0;
    }

    return 0;
  }

  // ==================== PAYMENTS ====================

  Future<List<PaymentModel>> getAllPayments({
    String? status,
    String? search,
  }) async {
    final queryParams = <String, String>{};
    if (status != null && status.isNotEmpty) queryParams['status'] = status;
    if (search != null && search.isNotEmpty) queryParams['search'] = search;

    final response = await _client.get(
      '/api/payments',
      queryParams: queryParams.isNotEmpty ? queryParams : null,
    );

    if (response.success && response.dataAsList != null) {
      return response.dataAsList!
          .map((e) => PaymentModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return [];
  }

  Future<PaymentModel> getPaymentById(String id) async {
    final response = await _client.get('/api/payments/$id');

    if (response.success && response.dataAsMap != null) {
      return PaymentModel.fromJson(response.dataAsMap!);
    }

    throw Exception(response.error ?? 'فشل جلب الدفعة');
  }

  Future<PaymentModel> approvePayment(String id) async {
    final response = await _client.put(
      '/api/payments/$id/approve',
      body: {},
    );

    if (response.success && response.dataAsMap != null) {
      return PaymentModel.fromJson(response.dataAsMap!);
    }

    throw Exception(response.error ?? 'فشل تأكيد الدفعة');
  }

  Future<PaymentModel> rejectPayment(String id, String? reason) async {
    final response = await _client.put(
      '/api/payments/$id/reject',
      body: {'reason': reason},
    );

    if (response.success && response.dataAsMap != null) {
      return PaymentModel.fromJson(response.dataAsMap!);
    }

    throw Exception(response.error ?? 'فشل رفض الدفعة');
  }

  // ==================== NOTIFICATIONS ====================

  Future<List<app_notif.NotificationModel>> getAllNotifications() async {
    final response = await _client.get('/api/notifications');

    if (response.success && response.dataAsList != null) {
      return response.dataAsList!
          .map((e) => app_notif.NotificationModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return [];
  }

  Future<app_notif.NotificationModel> sendNotification({
    required String title,
    required String message,
    required String targetType,
    String? targetRoles,
  }) async {
    final response = await _client.post(
      '/api/notifications',
      body: {
        'title': title,
        'message': message,
        'targetType': targetType,
        'targetRoles': targetRoles,
      },
    );

    if (response.success && response.dataAsMap != null) {
      return app_notif.NotificationModel.fromJson(response.dataAsMap!);
    }

    throw Exception(response.error ?? 'فشل إرسال الإشعار');
  }

  Future<int> getUnreadNotificationsCount() async {
    final response = await _client.get('/api/notifications/unread-count');

    if (response.success && response.dataAsMap != null) {
      return response.dataAsMap!['count'] as int? ?? 0;
    }

    return 0;
  }

  // ==================== REPORTS ====================

  Future<Map<String, dynamic>> getRevenueStats() async {
    final response = await _client.get('/api/reports/revenue');

    if (response.success && response.dataAsMap != null) {
      return response.dataAsMap!;
    }

    return {
      'total_revenue': 0.0,
      'approved_revenue': 0.0,
      'pending_revenue': 0.0,
      'monthly_revenue': <String, double>{},
    };
  }

  Future<Map<String, dynamic>> getAccountStatusStats() async {
    final response = await _client.get('/api/reports/accounts');

    if (response.success && response.dataAsMap != null) {
      return response.dataAsMap!;
    }

    return {
      'active': 0,
      'pending': 0,
      'suspended': 0,
      'rejected': 0,
      'providers': 0,
      'students': 0,
    };
  }

  // ==================== HELPERS ====================

  UserModel? _userFromJson(Map<String, dynamic>? data) {
    if (data == null) return null;
    return UserModel.fromJson(data);
  }
}