import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wasla_provider/shared/services/unified_auth_service.dart';
import '../models/user_model.dart';
import 'storage_service.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final UnifiedAuthService _unifiedAuthService =
      UnifiedAuthService(Supabase.instance.client);
  final StorageService _storageService = StorageService();

  Stream<AuthState> get authStateChanges => _unifiedAuthService.authStateChanges;

  Future<Map<String, dynamic>> signUp({
    required String email,
    required String password,
    required String name,
    String? phone,
    String? institutionType,
    String? institutionName,
  }) async {
    try {
      return await _unifiedAuthService.signUp(
        email: email,
        password: password,
        name: name,
        phone: phone,
        role: AuthRoles.provider,
        institutionType: _mapInstitutionType(institutionType),
        institutionName: institutionName,
      );
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final result = await _unifiedAuthService.signIn(
        email: email,
        password: password,
        requiredRole: AuthRoles.provider,
      );
      return UserModel.fromJson(result['profile']);
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  Future<void> signOut() async {
    await _unifiedAuthService.signOut();
  }

  User? getCurrentUser() {
    return _supabase.auth.currentUser;
  }

  Future<UserModel?> getCurrentUserProfile() async {
    final result = await _unifiedAuthService.getCurrentUser(requiredRole: AuthRoles.provider);
    if (result == null) return null;
    return UserModel.fromJson(result['profile']);
  }

  Future<void> resendConfirmationEmail(String email) async {
    await _unifiedAuthService.resendEmailConfirmation(email);
  }

  Future<UserModel> getUserProfile(String userId) async {
    try {
      final response = await _supabase.from('profiles').select().eq('id', userId).single();
      return UserModel.fromJson(response);
    } catch (_) {
      throw Exception('فشل في جلب بيانات المستخدم');
    }
  }

  Future<UserModel> updateProfile({
    required String userId,
    String? name,
    String? phone,
    String? institutionType,
    String? institutionName,
    String? bankAccount,
  }) async {
    try {
      final response = await _unifiedAuthService.updateProfile(
        userId: userId,
        name: name,
        phone: phone,
        institutionType: _mapInstitutionType(institutionType),
        institutionName: institutionName,
        bankAccount: bankAccount,
      );
      return UserModel.fromJson(response);
    } catch (_) {
      throw Exception('فشل في تحديث البيانات');
    }
  }

  Future<String> updateAvatar({
    required String userId,
    required dynamic imageFile,
  }) async {
    try {
      final url = await _storageService.uploadAvatar(
        file: imageFile,
        userId: userId,
      );

      await _supabase.from('profiles').update({'avatar': url}).eq('id', userId);
      return url;
    } catch (_) {
      throw Exception('فشل في تحديث الصورة الشخصية');
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('المستخدم غير مسجل الدخول');

      await _unifiedAuthService.signIn(
        email: user.email!,
        password: currentPassword,
        requiredRole: AuthRoles.provider,
      );

      await _unifiedAuthService.updatePassword(newPassword);
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  String? _mapInstitutionType(String? institutionType) {
    if (institutionType == null || institutionType.isEmpty) return null;

    switch (institutionType) {
      case 'جامعة':
        return 'UNIVERSITY';
      case 'مدرسة':
        return 'SCHOOL';
      case 'معهد':
        return 'INSTITUTE';
      case 'مركز تدريب':
        return 'TRAINING_CENTER';
      default:
        return 'INDEPENDENT';
    }
  }

  Exception _handleAuthError(dynamic error) {
    final message = error.toString();
    if (message.contains('INVALID_CREDENTIALS')) {
      return Exception('البريد الإلكتروني أو كلمة المرور غير صحيحة');
    }
    if (message.contains('EMAIL_EXISTS')) {
      return Exception('البريد الإلكتروني مسجل مسبقاً');
    }
    if (message.contains('EMAIL_NOT_CONFIRMED')) {
      return Exception('يرجى تأكيد البريد الإلكتروني أولاً');
    }
    if (message.contains('ACCOUNT_PENDING')) {
      return Exception('حسابك بانتظار موافقة الإدارة');
    }
    if (message.contains('ACCOUNT_LOCKED')) {
      return Exception('تم قفل الحساب مؤقتاً بسبب محاولات فاشلة متعددة');
    }
    if (message.contains('UNAUTHORIZED')) {
      return Exception('هذا الحساب غير مخصص لتطبيق مزود الخدمة');
    }
    if (message.contains('WEAK_PASSWORD')) {
      return Exception('كلمة المرور يجب أن تكون 8 أحرف على الأقل وتحتوي على حرف كبير ورقم ورمز خاص');
    }
    return Exception('حدث خطأ في المصادقة');
  }
}
