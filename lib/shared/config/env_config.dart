import 'package:flutter_dotenv/flutter_dotenv.dart';

/// تكوين متغيرات البيئة
/// Environment Configuration
class EnvConfig {
  /// رابط API الجديد (Flask Backend)
  static String get apiUrl => dotenv.env['API_URL'] ?? 'http://localhost:5000';

  /// مفتاح API للتوثيق
  static String get apiKey => dotenv.env['API_KEY'] ?? '';

  /// اسم التطبيق
  static String get appName => dotenv.env['APP_NAME'] ?? 'Wasla';

  /// إصدار التطبيق
  static String get appVersion => dotenv.env['APP_VERSION'] ?? '1.0.0';

  /// البيئة (development, staging, production)
  static String get environment => dotenv.env['ENVIRONMENT'] ?? 'development';

  /// هل البيئة تطوير؟
  static bool get isDevelopment => environment == 'development';

  /// هل البيئة إنتاج؟
  static bool get isProduction => environment == 'production';

  /// هل البيئة staging؟
  static bool get isStaging => environment == 'staging';

  /// تحميل متغيرات البيئة
  static Future<void> load() async {
    try {
      await dotenv.load(fileName: '.env');
    } catch (e) {
      print('⚠️ تحذير: فشل تحميل ملف .env - $e');
      print('⚠️ Warning: Failed to load .env file - $e');
    }
  }

  /// التحقق من صحة التكوين
  static bool validate() {
    if (apiUrl.isEmpty) {
      print('❌ خطأ: API_URL غير موجود في .env');
      print('❌ Error: API_URL not found in .env');
      return false;
    }

    return true;
  }
}
