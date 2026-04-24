import '../providers/auth_provider.dart';

class AuthController {
  final AuthProvider _provider;

  AuthController(this._provider);

  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
    String? phone,
    String? institutionType,
    String? institutionName,
  }) {
    // Validate email
    if (!email.contains('@')) {
      _provider.setError('البريد الإلكتروني غير صحيح');
      return Future.value(false);
    }
    // Validate password
    if (password.length < 6) {
      _provider.setError('كلمة المرور يجب أن تكون 6 أحرف على الأقل');
      return Future.value(false);
    }
    // Validate name
    if (name.trim().isEmpty) {
      _provider.setError('الاسم مطلوب');
      return Future.value(false);
    }
    return _provider.signUp(
      email: email,
      password: password,
      name: name,
      phone: phone,
      institutionType: institutionType,
      institutionName: institutionName,
    );
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) {
    if (email.trim().isEmpty || password.trim().isEmpty) {
      _provider.setError('البريد الإلكتروني وكلمة المرور مطلوبان');
      return Future.value(false);
    }
    return _provider.signIn(email: email, password: password);
  }

  Future<void> signOut() => _provider.signOut();
}
