import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import 'config/app_theme.dart';
import 'config/supabase_config.dart';
import 'config/routes.dart';
import 'providers/auth_provider.dart';
import 'providers/course_provider.dart';
import 'providers/enrollment_provider.dart';
import 'providers/exam_provider.dart';
import 'providers/certificate_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/search_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Catch and ignore Flutter Web keyboard errors
  FlutterError.onError = (FlutterErrorDetails details) {
    final exception = details.exception;
    final exceptionString = exception.toString();
    // Ignore keyboard-related type errors in web
    if (exceptionString.contains('shiftKey') ||
        exceptionString.contains('altKey') ||
        exceptionString.contains('ctrlKey') ||
        exceptionString.contains('metaKey')) {
      return;
    }
    FlutterError.presentError(details);
  };

  // Catch errors not caught by FlutterError.onError
  PlatformDispatcher.instance.onError = (error, stack) {
    final errorString = error.toString();
    // Ignore keyboard-related type errors in web
    if (errorString.contains('shiftKey') ||
        errorString.contains('altKey') ||
        errorString.contains('ctrlKey') ||
        errorString.contains('metaKey')) {
      return true;
    }
    return false;
  };

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
  );

  runApp(const WaslaStudentApp());
}

class WaslaStudentApp extends StatelessWidget {
  const WaslaStudentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CourseProvider()),
        ChangeNotifierProvider(create: (_) => EnrollmentProvider()),
        ChangeNotifierProvider(create: (_) => ExamProvider()),
        ChangeNotifierProvider(create: (_) => CertificateProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => SearchProvider()),
      ],
      child: MaterialApp.router(
        title: 'وسلة - منصة تعليمية',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: AppRouter.router,
        builder: (context, child) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: child ?? const SizedBox.shrink(),
          );
        },
      ),
    );
  }
}
