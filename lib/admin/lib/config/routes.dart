import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../views/screens/splash_screen.dart';
import '../views/screens/auth/login_screen.dart';
import '../views/screens/dashboard/dashboard_screen.dart';
import '../views/screens/accounts/accounts_screen.dart';
import '../views/screens/accounts/account_detail_screen.dart';
import '../views/screens/courses/courses_screen.dart';
import '../views/screens/courses/course_detail_screen.dart';
import '../views/screens/payments/payments_screen.dart';
import '../views/screens/payments/payment_detail_screen.dart';
import '../views/screens/notifications/notifications_screen.dart';
import '../views/screens/notifications/send_notification_screen.dart';
import '../views/screens/reports/reports_screen.dart';
import '../views/screens/profile/profile_screen.dart';
import '../views/screens/profile/settings_screen.dart';
import '../views/screens/profile/change_password_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String accounts = '/accounts';
  static const String accountDetail = '/accounts/:id';
  static const String courses = '/courses';
  static const String courseDetail = '/courses/:id';
  static const String payments = '/payments';
  static const String paymentDetail = '/payments/:id';
  static const String notifications = '/notifications';
  static const String sendNotification = '/notifications/send';
  static const String reports = '/reports';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String changePassword = '/change-password';

  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: splash,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isLoggedIn = _authService.isLoggedIn;
      final isLoginRoute = state.matchedLocation == login;
      final isSplashRoute = state.matchedLocation == splash;

      if (isSplashRoute) return null;

      if (!isLoggedIn && !isLoginRoute) return login;
      if (isLoggedIn && isLoginRoute) return dashboard;

      return null;
    },
    routes: [
      GoRoute(
        path: splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: dashboard,
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: accounts,
        builder: (context, state) => const AccountsScreen(),
      ),
      GoRoute(
        path: accountDetail,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return AccountDetailScreen(userId: id);
        },
      ),
      GoRoute(
        path: courses,
        builder: (context, state) => const CoursesScreen(),
      ),
      GoRoute(
        path: courseDetail,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return CourseDetailScreen(courseId: id);
        },
      ),
      GoRoute(
        path: payments,
        builder: (context, state) => const PaymentsScreen(),
      ),
      GoRoute(
        path: paymentDetail,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return PaymentDetailScreen(paymentId: id);
        },
      ),
      GoRoute(
        path: notifications,
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: sendNotification,
        builder: (context, state) => const SendNotificationScreen(),
      ),
      GoRoute(
        path: reports,
        builder: (context, state) => const ReportsScreen(),
      ),
      GoRoute(
        path: profile,
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: changePassword,
        builder: (context, state) => const ChangePasswordScreen(),
      ),
    ],
  );
}

// Simple auth service reference - will be replaced by actual AuthProvider
class _authService {
  static bool isLoggedIn = false;
}
