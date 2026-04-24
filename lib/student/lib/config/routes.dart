import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart' as p;

import '../providers/auth_provider.dart';
import '../views/screens/splash_screen.dart';
import '../views/screens/auth/login_screen.dart';
import '../views/screens/auth/register_screen.dart';
import '../views/screens/home/home_screen.dart';
import '../views/screens/search/search_screen.dart';
import '../views/screens/course/course_list_screen.dart';
import '../views/screens/course/course_detail_screen.dart';
import '../views/screens/course/course_content_screen.dart';
import '../views/screens/course/lesson_viewer_screen.dart';
import '../views/screens/enrollment/enroll_screen.dart';
import '../views/screens/enrollment/my_courses_screen.dart';
import '../views/screens/exam/exam_list_screen.dart';
import '../views/screens/exam/exam_take_screen.dart';
import '../views/screens/exam/exam_result_screen.dart';
import '../views/screens/certificate/certificates_screen.dart';
import '../views/screens/certificate/certificate_view_screen.dart';
import '../views/screens/profile/profile_screen.dart';
import '../views/screens/profile/edit_profile_screen.dart';
import '../views/screens/profile/achievements_screen.dart';
import '../views/screens/notification/notifications_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final authProvider = p.Provider.of<AuthProvider>(context, listen: false);
      final isLoggingIn = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';
      if (!authProvider.isAuthenticated && !isLoggingIn) {
        return '/login';
      }
      if (authProvider.isAuthenticated && isLoggingIn) {
        return '/home';
      }
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
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/search',
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: '/courses',
        builder: (context, state) => const CourseListScreen(),
      ),
      GoRoute(
        path: '/courses/:id',
        builder: (context, state) {
          final courseId = state.pathParameters['id']!;
          return CourseDetailScreen(courseId: courseId);
        },
      ),
      GoRoute(
        path: '/courses/:id/content',
        builder: (context, state) {
          final courseId = state.pathParameters['id']!;
          return CourseContentScreen(courseId: courseId);
        },
      ),
      GoRoute(
        path: '/courses/:id/modules/:moduleId/lessons/:lessonId',
        builder: (context, state) {
          final courseId = state.pathParameters['id']!;
          final moduleId = state.pathParameters['moduleId']!;
          final lessonId = state.pathParameters['lessonId']!;
          return LessonViewerScreen(
            courseId: courseId,
            moduleId: moduleId,
            lessonId: lessonId,
          );
        },
      ),
      GoRoute(
        path: '/courses/:id/enroll',
        builder: (context, state) {
          final courseId = state.pathParameters['id']!;
          return EnrollScreen(courseId: courseId);
        },
      ),
      GoRoute(
        path: '/my-courses',
        builder: (context, state) => const MyCoursesScreen(),
      ),
      GoRoute(
        path: '/exams/:examId/take',
        builder: (context, state) {
          final examId = state.pathParameters['examId']!;
          return ExamTakeScreen(examId: examId);
        },
      ),
      GoRoute(
        path: '/exams/:examId/result/:attemptId',
        builder: (context, state) {
          final examId = state.pathParameters['examId']!;
          final attemptId = state.pathParameters['attemptId']!;
          return ExamResultScreen(examId: examId, attemptId: attemptId);
        },
      ),
      GoRoute(
        path: '/certificates',
        builder: (context, state) => const CertificatesScreen(),
      ),
      GoRoute(
        path: '/certificates/:id',
        builder: (context, state) {
          final certId = state.pathParameters['id']!;
          return CertificateViewScreen(certificateId: certId);
        },
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/profile/edit',
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/profile/achievements',
        builder: (context, state) => const AchievementsScreen(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text(
          'الصفحة غير موجودة',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
    ),
  );
}
