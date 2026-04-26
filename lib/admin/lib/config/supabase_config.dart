
import 'package:wasla_provider/shared/config/env_config.dart';

class SupabaseConfig {
  static String get supabaseUrl => EnvConfig.supabaseUrl;
  static String get supabaseAnonKey => EnvConfig.supabaseAnonKey;

  static const String profilesTable = 'profiles';
  static const String coursesTable = 'courses';
  static const String paymentsTable = 'payments';
  static const String notificationsTable = 'notifications';
  static const String enrollmentsTable = 'enrollments';
  static const String certificatesTable = 'certificates';
  static const String settingsTable = 'system_settings';

  static const String storageBucket = 'avatars';
}
