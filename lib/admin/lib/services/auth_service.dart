import '../models/user_model.dart';
import 'supabase_service.dart';

class AuthService {
  final SupabaseService _supabaseService;

  AuthService(this._supabaseService);

  Future<UserModel> signIn(String email, String password) async {
    final user = await _supabaseService.signIn(email, password);
    if (user == null) {
      throw Exception('فشل تسجيل الدخول. تحقق من البيانات.');
    }
    if (user.role != 'ADMIN') {
      await _supabaseService.signOut();
      throw Exception('هذا الحساب ليس حساب مشرف. الوصول مرفوض.');
    }
    return user;
  }

  Future<void> signOut() async {
    await _supabaseService.signOut();
  }

  Future<UserModel?> getCurrentUser() async {
    return await _supabaseService.getCurrentUser();
  }

  Future<bool> isAdmin() async {
    return await _supabaseService.isAdmin();
  }

  Future<void> updatePassword(String newPassword) async {
    await _supabaseService.updatePassword(newPassword);
  }
}
