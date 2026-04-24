import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/user_model.dart';
import '../models/course_model.dart';
import '../models/payment_model.dart';
import '../models/notification_model.dart' as app_notif;
import '../models/stats_model.dart';
import '../models/monthly_stats_model.dart';

class SupabaseService {
  final SupabaseClient _client;

  SupabaseService(this._client);

  // ==================== AUTH ====================

  Future<UserModel?> signIn(String email, String password) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    final user = response.user;
    if (user == null) return null;

    final profile = await _client
        .from(SupabaseConfig.profilesTable)
        .select()
        .eq('id', user.id)
        .single();

    return UserModel.fromJson({...profile, 'email': user.email});
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  Future<UserModel?> getCurrentUser() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;

    try {
      final profile = await _client
          .from(SupabaseConfig.profilesTable)
          .select()
          .eq('id', user.id)
          .single();

      return UserModel.fromJson({...profile, 'email': user.email});
    } catch (_) {
      return null;
    }
  }

  Future<bool> isAdmin() async {
    final user = _client.auth.currentUser;
    if (user == null) return false;

    try {
      final profile = await _client
          .from(SupabaseConfig.profilesTable)
          .select('role')
          .eq('id', user.id)
          .single();

      return profile['role'] == 'ADMIN';
    } catch (_) {
      return false;
    }
  }

  Future<void> updatePassword(String newPassword) async {
    await _client.auth.updateUser(
      UserAttributes(password: newPassword),
    );
  }

  // ==================== DASHBOARD ====================

  Future<StatsModel> getStats() async {
    try {
      final response = await _client.rpc('get_admin_stats');
      return StatsModel.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      // Fallback: manual stats calculation
      return _calculateStatsManually();
    }
  }

  Future<StatsModel> _calculateStatsManually() async {
    final profiles = await _client.from(SupabaseConfig.profilesTable).select();

    int activeProviders = 0;
    int pendingAccounts = 0;
    int suspendedAccounts = 0;
    int totalStudents = 0;

    for (final p in profiles) {
      final role = p['role'] as String? ?? '';
      final status = p['status'] as String? ?? '';
      if (role == 'PROVIDER' && status == 'ACTIVE') activeProviders++;
      if (status == 'PENDING') pendingAccounts++;
      if (status == 'SUSPENDED') suspendedAccounts++;
      if (role == 'STUDENT') totalStudents++;
    }

    final courses =
        await _client.from(SupabaseConfig.coursesTable).select('id');

    final payments = await _client
        .from(SupabaseConfig.paymentsTable)
        .select('amount, status');

    double totalRevenue = 0;
    int totalPayments = payments.length;
    for (final p in payments) {
      if (p['status'] == 'APPROVED') {
        totalRevenue += (p['amount'] as num?)?.toDouble() ?? 0;
      }
    }

    return StatsModel(
      activeProviders: activeProviders,
      pendingAccounts: pendingAccounts,
      suspendedAccounts: suspendedAccounts,
      totalStudents: totalStudents,
      totalCourses: courses.length,
      totalRevenue: totalRevenue,
      totalPayments: totalPayments,
      totalNotifications: 0,
    );
  }

  Future<List<MonthlyStatsModel>> getMonthlyStats() async {
    try {
      final response = await _client.rpc('get_monthly_stats');
      return (response as List)
          .map((e) => MonthlyStatsModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // ==================== ACCOUNTS ====================

  Future<List<UserModel>> getAllAccounts({
    String? role,
    String? status,
    String? search,
  }) async {
    dynamic query = _client
        .from(SupabaseConfig.profilesTable)
        .select()
        .order('created_at', ascending: false);

    if (role != null && role.isNotEmpty) {
      query = query.eq('role', role);
    }
    if (status != null && status.isNotEmpty) {
      query = query.eq('status', status);
    }
    if (search != null && search.isNotEmpty) {
      query = query.or('full_name.ilike.%$search%,email.ilike.%$search%');
    }

    final response = await query;
    return response.map((e) => UserModel.fromJson(e)).toList();
  }

  Future<UserModel> getAccountById(String id) async {
    final response = await _client
        .from(SupabaseConfig.profilesTable)
        .select()
        .eq('id', id)
        .single();
    return UserModel.fromJson(response);
  }

  Future<UserModel> updateAccountStatus(String id, String status) async {
    final response = await _client
        .from(SupabaseConfig.profilesTable)
        .update(
            {'status': status, 'updated_at': DateTime.now().toIso8601String()})
        .eq('id', id)
        .select()
        .single();
    return UserModel.fromJson(response);
  }

  Future<List<UserModel>> getPendingAccounts() async {
    final response = await _client
        .from(SupabaseConfig.profilesTable)
        .select()
        .eq('status', 'PENDING')
        .order('created_at', ascending: false);
    return response.map((e) => UserModel.fromJson(e)).toList();
  }

  // ==================== COURSES ====================

  Future<List<CourseModel>> getAllCourses({
    String? status,
    String? search,
  }) async {
    dynamic query = _client
        .from(SupabaseConfig.coursesTable)
        .select('*, profiles!courses_provider_id_fkey(full_name, avatar_url)')
        .order('created_at', ascending: false);

    if (status != null && status.isNotEmpty) {
      query = query.eq('status', status);
    }
    if (search != null && search.isNotEmpty) {
      query = query.ilike('title', '%$search%');
    }

    final response = await query;
    return response.map((e) {
      final courseMap = Map<String, dynamic>.from(e);
      final profile = courseMap.remove('profiles');
      if (profile != null && profile is Map) {
        courseMap['provider_name'] = profile['full_name'];
        courseMap['provider_avatar'] = profile['avatar_url'];
      }
      return CourseModel.fromJson(courseMap);
    }).toList();
  }

  Future<CourseModel> getCourseById(String id) async {
    final response = await _client
        .from(SupabaseConfig.coursesTable)
        .select('*, profiles!courses_provider_id_fkey(full_name, avatar_url)')
        .eq('id', id)
        .single();

    final courseMap = Map<String, dynamic>.from(response);
    final profile = courseMap.remove('profiles');
    if (profile != null && profile is Map) {
      courseMap['provider_name'] = profile['full_name'];
      courseMap['provider_avatar'] = profile['avatar_url'];
    }
    return CourseModel.fromJson(courseMap);
  }

  Future<CourseModel> updateCourseStatus(String id, String status) async {
    final response = await _client
        .from(SupabaseConfig.coursesTable)
        .update(
            {'status': status, 'updated_at': DateTime.now().toIso8601String()})
        .eq('id', id)
        .select()
        .single();
    return CourseModel.fromJson(response);
  }

  Future<int> getCourseEnrollmentsCount(String courseId) async {
    final response = await _client
        .from(SupabaseConfig.enrollmentsTable)
        .select()
        .eq('course_id', courseId);
    return response.length;
  }

  // ==================== PAYMENTS ====================

  Future<List<PaymentModel>> getAllPayments({
    String? status,
    String? search,
  }) async {
    dynamic query = _client
        .from(SupabaseConfig.paymentsTable)
        .select(
            '*, profiles!payments_user_id_fkey(full_name, avatar_url), courses(title)')
        .order('created_at', ascending: false);

    if (status != null && status.isNotEmpty) {
      query = query.eq('status', status);
    }
    if (search != null && search.isNotEmpty) {
      query = query.or('profiles.full_name.ilike.%$search%');
    }

    final response = await query;
    return response.map((e) {
      final paymentMap = Map<String, dynamic>.from(e);
      final profile = paymentMap.remove('profiles');
      final course = paymentMap.remove('courses');
      if (profile != null && profile is Map) {
        paymentMap['user_name'] = profile['full_name'];
        paymentMap['user_avatar'] = profile['avatar_url'];
      }
      if (course != null && course is Map) {
        paymentMap['course_title'] = course['title'];
      }
      return PaymentModel.fromJson(paymentMap);
    }).toList();
  }

  Future<PaymentModel> getPaymentById(String id) async {
    final response = await _client
        .from(SupabaseConfig.paymentsTable)
        .select(
            '*, profiles!payments_user_id_fkey(full_name, avatar_url), courses(title)')
        .eq('id', id)
        .single();

    final paymentMap = Map<String, dynamic>.from(response);
    final profile = paymentMap.remove('profiles');
    final course = paymentMap.remove('courses');
    if (profile != null && profile is Map) {
      paymentMap['user_name'] = profile['full_name'];
      paymentMap['user_avatar'] = profile['avatar_url'];
    }
    if (course != null && course is Map) {
      paymentMap['course_title'] = course['title'];
    }
    return PaymentModel.fromJson(paymentMap);
  }

  Future<PaymentModel> approvePayment(String id) async {
    final response = await _client
        .from(SupabaseConfig.paymentsTable)
        .update({
          'status': 'APPROVED',
          'processed_at': DateTime.now().toIso8601String(),
        })
        .eq('id', id)
        .select()
        .single();
    return PaymentModel.fromJson(response);
  }

  Future<PaymentModel> rejectPayment(String id, String? reason) async {
    final response = await _client
        .from(SupabaseConfig.paymentsTable)
        .update({
          'status': 'REJECTED',
          'notes': reason,
          'processed_at': DateTime.now().toIso8601String(),
        })
        .eq('id', id)
        .select()
        .single();
    return PaymentModel.fromJson(response);
  }

  // ==================== NOTIFICATIONS ====================

  Future<List<app_notif.NotificationModel>> getAllNotifications() async {
    final response = await _client
        .from(SupabaseConfig.notificationsTable)
        .select()
        .order('created_at', ascending: false);
    return response
        .map((e) => app_notif.NotificationModel.fromJson(e))
        .toList();
  }

  Future<app_notif.NotificationModel> sendNotification({
    required String title,
    required String message,
    required String targetType,
    String? targetRoles,
  }) async {
    final user = _client.auth.currentUser;

    final data = {
      'title': title,
      'body': message,
      'sender_id': user?.id,
      'sent_to_all': targetType == 'ALL' ? true : false,
      'target_roles': targetType == 'ALL' ? null : targetRoles,
      'created_at': DateTime.now().toIso8601String(),
    };

    final response = await _client
        .from(SupabaseConfig.notificationsTable)
        .insert(data)
        .select()
        .single();

    return app_notif.NotificationModel.fromJson(response);
  }

  Future<int> getUnreadNotificationsCount() async {
    final user = _client.auth.currentUser;
    if (user == null) return 0;

    final response = await _client
        .from(SupabaseConfig.notificationsTable)
        .select()
        .eq('sender_id', user.id);

    return response.length;
  }

  // ==================== REPORTS ====================

  Future<Map<String, dynamic>> getRevenueStats() async {
    final payments = await _client
        .from(SupabaseConfig.paymentsTable)
        .select('amount, status, created_at');

    double totalRevenue = 0;
    double approvedRevenue = 0;
    double pendingRevenue = 0;
    final monthlyRevenue = <String, double>{};

    for (final p in payments) {
      final amount = (p['amount'] as num?)?.toDouble() ?? 0;
      final status = p['status'] as String? ?? '';
      final createdAt = p['created_at'] as String?;

      if (status == 'APPROVED') {
        approvedRevenue += amount;
        totalRevenue += amount;
      } else if (status == 'PENDING') {
        pendingRevenue += amount;
      }

      if (createdAt != null) {
        try {
          final date = DateTime.parse(createdAt);
          final key = '${date.year}-${date.month.toString().padLeft(2, '0')}';
          monthlyRevenue[key] = (monthlyRevenue[key] ?? 0) + amount;
        } catch (_) {}
      }
    }

    return {
      'total_revenue': totalRevenue,
      'approved_revenue': approvedRevenue,
      'pending_revenue': pendingRevenue,
      'monthly_revenue': monthlyRevenue,
    };
  }

  Future<Map<String, dynamic>> getAccountStatusStats() async {
    final profiles = await _client.from(SupabaseConfig.profilesTable).select();

    int active = 0;
    int pending = 0;
    int suspended = 0;
    int rejected = 0;
    int providers = 0;
    int students = 0;

    for (final p in profiles) {
      final status = p['status'] as String? ?? '';
      final role = p['role'] as String? ?? '';
      switch (status) {
        case 'ACTIVE':
          active++;
          break;
        case 'PENDING':
          pending++;
          break;
        case 'SUSPENDED':
          suspended++;
          break;
        case 'REJECTED':
          rejected++;
          break;
      }
      if (role == 'PROVIDER') providers++;
      if (role == 'STUDENT') students++;
    }

    return {
      'active': active,
      'pending': pending,
      'suspended': suspended,
      'rejected': rejected,
      'providers': providers,
      'students': students,
    };
  }

  // ==================== SETTINGS ====================

  Future<Map<String, String>> getSettings() async {
    final response = await _client.from(SupabaseConfig.settingsTable).select();

    final settings = <String, String>{};
    for (final item in response) {
      settings[item['key'] as String] = item['value']?.toString() ?? '';
    }
    return settings;
  }

  Future<void> updateSetting(String key, String value) async {
    await _client
        .from(SupabaseConfig.settingsTable)
        .update({'value': value}).eq('key', key);
  }
}
