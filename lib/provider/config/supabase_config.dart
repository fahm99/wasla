import '../../shared/config/env_config.dart';

class SupabaseConfig {
  static String get supabaseUrl => EnvConfig.supabaseUrl;
  static String get supabaseAnonKey => EnvConfig.supabaseAnonKey;
}
