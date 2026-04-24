import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import 'storage_service.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final StorageService _storageService = StorageService();

  // Sign up
  Future<UserModel> signUp({
    required String email,
    required String password,
    required String name,
    String? phone,
    String? institutionType,
    String? institutionName,
  }) async {
    try {
      // تحويل نوع المؤسسة إلى الصيغة الصحيحة
      String? institutionTypeEnum;
      if (institutionType != null) {
        switch (institutionType) {
          case 'جامعة':
            institutionTypeEnum = 'UNIVERSITY';
            break;
          case 'مدرسة':
            institutionTypeEnum = 'SCHOOL';
            break;
          case 'معهد':
            institutionTypeEnum = 'INSTITUTE';
            break;
          case 'مركز تدريب':
            institutionTypeEnum = 'TRAINING_CENTER';
            break;
          default:
            institutionTypeEnum = 'INDEPENDENT';
        }
      }

      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'name': name,
          'phone': phone,
          'role': 'PROVIDER', // دائماً مزود خدمة
          'institution_type': institutionTypeEnum,
          'institution_name': institutionName,
        },
      );

      if (response.user == null) {
        throw Exception('فشل في إنشاء الحساب');
      }

      // الانتظار قليلاً للسماح للـ trigger بإنشاء السجل
      await Future.delayed(const Duration(milliseconds: 500));

      // جلب بيانات المستخدم من قاعدة البيانات
      return await getUserProfile(response.user!.id);
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Sign in
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception('فشل في تسجيل الدخول');
      }

      return await getUserProfile(response.user!.id);
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  // Get current user
  User? getCurrentUser() {
    return _supabase.auth.currentUser;
  }

  // Get user profile from profiles table
  Future<UserModel> getUserProfile(String userId) async {
    try {
      final response =
          await _supabase.from('profiles').select().eq('id', userId).single();

      return UserModel.fromJson(response);
    } catch (e) {
      throw Exception('فشل في جلب بيانات المستخدم');
    }
  }

  // Update profile
  Future<UserModel> updateProfile({
    required String userId,
    String? name,
    String? phone,
    String? institutionType,
    String? institutionName,
    String? bankAccount,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (phone != null) updates['phone'] = phone;
      if (institutionType != null) {
        updates['institution_type'] = institutionType;
      }
      if (institutionName != null) {
        updates['institution_name'] = institutionName;
      }
      if (bankAccount != null) updates['bank_account'] = bankAccount;
      updates['updated_at'] = DateTime.now().toIso8601String();

      await _supabase.from('profiles').update(updates).eq('id', userId);

      return await getUserProfile(userId);
    } catch (e) {
      throw Exception('فشل في تحديث البيانات');
    }
  }

  // Update avatar
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
    } catch (e) {
      throw Exception('فشل في تحديث الصورة الشخصية');
    }
  }

  // Change password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      // Verify current password by re-authenticating
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('المستخدم غير مسجل الدخول');

      await _supabase.auth.signInWithPassword(
        email: user.email!,
        password: currentPassword,
      );

      await _supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );
    } on AuthException catch (e) {
      if (e.message.contains('Invalid login')) {
        throw Exception('كلمة المرور الحالية غير صحيحة');
      }
      throw Exception('فشل في تغيير كلمة المرور');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('فشل في تغيير كلمة المرور');
    }
  }

  // Listen to auth state changes
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  Exception _handleAuthError(dynamic error) {
    if (error is AuthException) {
      switch (error.message) {
        case 'Invalid login credentials':
          return Exception('البريد الإلكتروني أو كلمة المرور غير صحيحة');
        case 'User already registered':
          return Exception('البريد الإلكتروني مسجل مسبقاً');
        case 'Password should be at least 6 characters.':
          return Exception('كلمة المرور يجب أن تكون 6 أحرف على الأقل');
        default:
          return Exception('خطأ في المصادقة: ${error.message}');
      }
    }
    if (error is PostgrestException) {
      return Exception('خطأ في قاعدة البيانات: ${error.message}');
    }
    if (error is Exception) {
      return error;
    }
    return Exception('حدث خطأ غير متوقع: $error');
  }
}
