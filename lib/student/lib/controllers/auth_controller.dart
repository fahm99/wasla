import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthController {
  Future<UserModel> signUp({
    required String name,
    required String email,
    required String password,
    String? phone,
    String? gender,
  }) async {
    return await AuthService.signUp(
      name: name,
      email: email,
      password: password,
      phone: phone,
      gender: gender,
    );
  }

  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    return await AuthService.signIn(email: email, password: password);
  }

  Future<void> signOut() async {
    await AuthService.signOut();
  }

  Future<UserModel?> getCurrentUser() async {
    return await AuthService.getCurrentUser();
  }

  Future<void> resetPassword(String email) async {
    await AuthService.resetPassword(email);
  }

  Future<void> updateProfile({
    required String name,
    required String email,
    String? phone,
    String? bio,
    String? gender,
    String? avatar,
  }) async {
    await AuthService.updateProfile(
      name: name,
      email: email,
      phone: phone,
      bio: bio,
      gender: gender,
      avatar: avatar,
    );
  }

  bool validateName(String name) {
    return name.trim().length >= 3;
  }

  bool validateEmail(String email) {
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return regex.hasMatch(email);
  }

  bool validatePassword(String password) {
    return password.length >= 8;
  }

  bool validatePhone(String phone) {
    if (phone.isEmpty) return true;
    final regex = RegExp(r'^[+]?[0-9]{10,14}$');
    return regex.hasMatch(phone.replaceAll(' ', ''));
  }

  bool validateConfirmPassword(String password, String confirmPassword) {
    return password == confirmPassword;
  }
}
