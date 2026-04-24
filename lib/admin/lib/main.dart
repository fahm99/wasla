import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';

import 'config/app_theme.dart';
import 'config/supabase_config.dart';
import 'providers/auth_provider.dart';
import 'providers/dashboard_provider.dart';
import 'providers/accounts_provider.dart';
import 'providers/courses_provider.dart';
import 'providers/payments_provider.dart';
import 'providers/notifications_provider.dart';
import 'services/supabase_service.dart';
import 'services/storage_service.dart';
import 'views/screens/splash_screen.dart';
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

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: AppTheme.primaryDarkBlue,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
  ));

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
  );

  runApp(const WaslaAdminApp());
}

class WaslaAdminApp extends StatelessWidget {
  const WaslaAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    final supabaseClient = Supabase.instance.client;
    final supabaseService = SupabaseService(supabaseClient);
    final storageService = StorageService(supabaseClient);

    return MultiProvider(
      providers: [
        Provider<SupabaseService>.value(value: supabaseService),
        Provider<StorageService>.value(value: storageService),
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(supabaseService),
        ),
        ChangeNotifierProvider<DashboardProvider>(
          create: (_) => DashboardProvider(supabaseService),
        ),
        ChangeNotifierProvider<AccountsProvider>(
          create: (_) => AccountsProvider(supabaseService),
        ),
        ChangeNotifierProvider<CoursesProvider>(
          create: (_) => CoursesProvider(supabaseService),
        ),
        ChangeNotifierProvider<PaymentsProvider>(
          create: (_) => PaymentsProvider(supabaseService),
        ),
        ChangeNotifierProvider<NotificationsProvider>(
          create: (_) => NotificationsProvider(supabaseService),
        ),
      ],
      child: MaterialApp.router(
        title: 'وصلة - لوحة تحكم المشرف',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: _router,
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
      ),
    );
  }

  static final _router = GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final user = Supabase.instance.client.auth.currentUser;
      final isLoggedIn = user != null;
      final isLoginRoute = state.matchedLocation == '/login';
      final isSplashRoute = state.matchedLocation == '/';

      if (isSplashRoute) return null;
      if (!isLoggedIn && !isLoginRoute) return '/login';
      if (isLoggedIn && isLoginRoute) return '/dashboard';
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
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
