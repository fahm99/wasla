import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/app_theme.dart';
import 'config/supabase_config.dart';
import 'config/routes.dart';
import 'providers/auth_provider.dart';
import 'providers/course_provider.dart';
import 'providers/module_provider.dart';
import 'providers/lesson_provider.dart';
import 'providers/exam_provider.dart';
import 'providers/certificate_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/payment_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CourseProvider()),
        ChangeNotifierProvider(create: (_) => ModuleProvider()),
        ChangeNotifierProvider(create: (_) => LessonProvider()),
        ChangeNotifierProvider(create: (_) => ExamProvider()),
        ChangeNotifierProvider(create: (_) => CertificateProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => PaymentProvider()),
      ],
      child: const WaslaProviderApp(),
    ),
  );
}

class WaslaProviderApp extends StatelessWidget {
  const WaslaProviderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'وصلة - مزود الخدمة',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ar', 'SA'),
      ],
      locale: const Locale('ar', 'SA'),
      routerConfig: AppRoutes.router,
    );
  }
}
