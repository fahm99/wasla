import '../models/user_model.dart';
import 'supabase_service.dart';

class AuthService {
  static Future<UserModel> signUp({
    required String name,
    required String email,
    required String password,
    String? phone,
    String? gender,
  }) async {
    return await SupabaseService.signUp(
      name: name,
      email: email,
      password: password,
      phone: phone,
      gender: gender,
    );
  }

  static Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    return await SupabaseService.signIn(email: email, password: password);
  }

  static Future<void> signOut() async {
    await SupabaseService.signOut();
  }

  static Future<UserModel?> getCurrentUser() async {
    return await SupabaseService.getCurrentUser();
  }

  static Future<void> resetPassword(String email) async {
    await SupabaseService.resetPassword(email);
  }

  static Future<void> updateProfile({
    required String name,
    required String email,
    String? phone,
    String? bio,
    String? gender,
    String? avatar,
  }) async {
    await SupabaseService.updateProfile(
      name: name,
      email: email,
      phone: phone,
      bio: bio,
      gender: gender,
      avatar: avatar,
    );
  }
}
