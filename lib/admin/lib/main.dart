import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:wasla_provider/shared/config/env_config.dart';
import 'package:wasla_provider/shared/services/api_client.dart';
import 'package:wasla_provider/shared/services/flask_api_service.dart';
import 'package:wasla_provider/shared/services/auth_service.dart';
import 'dart:ui';

import 'config/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/dashboard_provider.dart';
import 'providers/accounts_provider.dart';
import 'providers/courses_provider.dart';
import 'providers/payments_provider.dart';
import 'providers/notifications_provider.dart';
import 'services/storage_service.dart';
import 'views/screens/auth/login_screen.dart';
import 'views/screens/dashboard/dashboard_screen.dart';
import 'views/screens/accounts/accounts_screen.dart';
import 'views/screens/accounts/account_detail_screen.dart';
import 'views/screens/courses/courses_screen.dart';
import 'views/screens/courses/course_detail_screen.dart';
import 'views/screens/payments/payments_screen.dart';
import 'views/screens/payments/payment_detail_screen.dart';
import 'views/screens/notifications/notifications_screen.dart';
import 'views/screens/notifications/send_notification_screen.dart';
import 'views/screens/reports/reports_screen.dart';
import 'views/screens/profile/profile_screen.dart';
import 'views/screens/profile/settings_screen.dart';
import 'views/screens/profile/change_password_screen.dart';

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

  await EnvConfig.load();

  if (!EnvConfig.validate()) {
    throw Exception('Invalid environment configuration');
  }

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: AppTheme.primaryDarkBlue,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
  ));

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // لا حاجة لـ Supabase.initialize - نستخدم REST API
  runApp(const WaslaAdminApp());
}

class WaslaAdminApp extends StatelessWidget {
  const WaslaAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    final flaskApiService = FlaskApiService();
    final authService = AuthService();
    final storageService = StorageService();

    return MultiProvider(
      providers: [
        Provider<FlaskApiService>.value(value: flaskApiService),
        Provider<AuthService>.value(value: authService),
        Provider<StorageService>.value(value: storageService),
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(),
        ),
        ChangeNotifierProvider<DashboardProvider>(
          create: (_) => DashboardProvider(flaskApiService),
        ),
        ChangeNotifierProvider<AccountsProvider>(
          create: (_) => AccountsProvider(flaskApiService),
        ),
        ChangeNotifierProvider<CoursesProvider>(
          create: (_) => CoursesProvider(flaskApiService),
        ),
        ChangeNotifierProvider<PaymentsProvider>(
          create: (_) => PaymentsProvider(flaskApiService),
        ),
        ChangeNotifierProvider<NotificationsProvider>(
          create: (_) => NotificationsProvider(flaskApiService),
        ),
      ],
      child: Builder(
        builder: (context) {
          final authProvider = context.watch<AuthProvider>();
          final router = _buildRouter(authProvider);

          return MaterialApp.router(
            title: 'وصلة - لوحة تحكم المشرف',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            routerConfig: router,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('ar', 'SA'),
              Locale('ar'),
              Locale('en', 'US'),
            ],
            locale: const Locale('ar', 'SA'),
            builder: (context, child) {
              return Directionality(
                textDirection: TextDirection.rtl,
                child: child ?? const SizedBox(),
              );
            },
          );
        },
      ),
    );
  }

  GoRouter _buildRouter(AuthProvider authProvider) {
    return GoRouter(
      initialLocation: '/login',
      refreshListenable: authProvider,
      redirect: (context, state) {
        final isLoggedIn = authProvider.isAuthenticated;
        final isLoginRoute = state.matchedLocation == '/login';

        // Protect authenticated routes
        if (!isLoggedIn && !isLoginRoute) return '/login';

        // Redirect to dashboard if already logged in and trying to access login
        if (isLoggedIn && isLoginRoute) return '/dashboard';

        return null;
      },
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: '/accounts',
          builder: (context, state) => const AccountsScreen(),
        ),
        GoRoute(
          path: '/accounts/:id',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return AccountDetailScreen(userId: id);
          },
        ),
        GoRoute(
          path: '/courses',
          builder: (context, state) => const CoursesScreen(),
        ),
        GoRoute(
          path: '/courses/:id',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return CourseDetailScreen(courseId: id);
          },
        ),
        GoRoute(
          path: '/payments',
          builder: (context, state) => const PaymentsScreen(),
        ),
        GoRoute(
          path: '/payments/:id',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return PaymentDetailScreen(paymentId: id);
          },
        ),
        GoRoute(
          path: '/notifications',
          builder: (context, state) => const NotificationsScreen(),
        ),
        GoRoute(
          path: '/notifications/send',
          builder: (context, state) => const SendNotificationScreen(),
        ),
        GoRoute(
          path: '/reports',
          builder: (context, state) => const ReportsScreen(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen(),
        ),
        GoRoute(
          path: '/change-password',
          builder: (context, state) => const ChangePasswordScreen(),
        ),
      ],
    );
  }
}
