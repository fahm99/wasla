import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:ui';
import 'shared/config/env_config.dart';
import 'shared/views/user_type_selection_screen.dart';

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

  // تحميل متغيرات البيئة
  await EnvConfig.load();

  // التحقق من صحة التكوين
  if (!EnvConfig.validate()) {
    throw Exception('Invalid environment configuration');
  }

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Color(0xFF1E3A5F),
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
  ));

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await Supabase.initialize(
    url: EnvConfig.supabaseUrl,
    anonKey: EnvConfig.supabaseAnonKey,
  );

  runApp(const WaslaApp());
}

class WaslaApp extends StatelessWidget {
  const WaslaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'وصلة - منصة تعليمية',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF1E3A5F),
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Cairo',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E3A5F),
          primary: const Color(0xFF1E3A5F),
          secondary: const Color(0xFFFFC107),
        ),
      ),
      home: const UserTypeSelectionScreen(),
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child ?? const SizedBox(),
        );
      },
    );
  }
}
