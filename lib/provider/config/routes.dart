import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../views/screens/auth/login_screen.dart';
import '../views/screens/auth/register_screen.dart';
import '../views/screens/main/dashboard_screen.dart';
import '../views/screens/courses/courses_list_screen.dart';
import '../views/screens/courses/course_detail_screen.dart';
import '../views/screens/courses/add_edit_course_screen.dart';
import '../views/screens/modules/modules_screen.dart';
import '../views/screens/modules/add_edit_module_screen.dart';
import '../views/screens/lessons/lessons_screen.dart';
import '../views/screens/lessons/add_edit_lesson_screen.dart';
import '../views/screens/lessons/lesson_content_screen.dart';
import '../views/screens/exams/exams_list_screen.dart';
import '../views/screens/exams/add_edit_exam_screen.dart';
import '../views/screens/exams/questions_screen.dart';
import '../views/screens/exams/add_edit_question_screen.dart';
import '../views/screens/students/students_list_screen.dart';
import '../views/screens/certificates/certificates_screen.dart';
import '../views/screens/certificates/certificate_templates_screen.dart';
import '../views/screens/profile/profile_screen.dart';
import '../views/screens/profile/edit_profile_screen.dart';
import '../views/screens/profile/change_password_screen.dart';
import '../views/screens/payments/payments_screen.dart';
import '../views/screens/payments/upload_payment_screen.dart';
import '../views/screens/notifications/notifications_screen.dart';

class AppRoutes {
  static final GoRouter router = GoRouter(
    initialLocation: '/login',
    redirect: (BuildContext context, GoRouterState state) {
      final authProvider = context.read<AuthProvider>();
      final isLoggedIn = authProvider.isAuthenticated;
      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';
      if (!isLoggedIn && !isAuthRoute) {
        return '/login';
      }
      if (isLoggedIn && isAuthRoute) {
        return '/dashboard';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/courses',
        builder: (context, state) => const CoursesListScreen(),
      ),
      GoRoute(
        path: '/courses/new',
        builder: (context, state) => const AddEditCourseScreen(),
      ),
      GoRoute(
        path: '/courses/:id',
        builder: (context, state) => CourseDetailScreen(
          courseId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/courses/:id/edit',
        builder: (context, state) => AddEditCourseScreen(
          courseId: state.pathParameters['id'],
        ),
      ),
      GoRoute(
        path: '/courses/:id/modules',
        builder: (context, state) => ModulesScreen(
          courseId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/courses/:id/modules/new',
        builder: (context, state) => AddEditModuleScreen(
          courseId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/courses/:id/modules/:moduleId/edit',
        builder: (context, state) => AddEditModuleScreen(
          courseId: state.pathParameters['id']!,
          moduleId: state.pathParameters['moduleId'],
        ),
      ),
      GoRoute(
        path: '/courses/:id/modules/:moduleId/lessons',
        builder: (context, state) => LessonsScreen(
          courseId: state.pathParameters['id']!,
          moduleId: state.pathParameters['moduleId']!,
        ),
      ),
      GoRoute(
        path: '/courses/:id/modules/:moduleId/lessons/new',
        builder: (context, state) => AddEditLessonScreen(
          courseId: state.pathParameters['id']!,
          moduleId: state.pathParameters['moduleId']!,
        ),
      ),
      GoRoute(
        path: '/courses/:id/modules/:moduleId/lessons/:lessonId/edit',
        builder: (context, state) => AddEditLessonScreen(
          courseId: state.pathParameters['id']!,
          moduleId: state.pathParameters['moduleId']!,
          lessonId: state.pathParameters['lessonId'],
        ),
      ),
      GoRoute(
        path: '/courses/:id/modules/:moduleId/lessons/:lessonId/content',
        builder: (context, state) => LessonContentScreen(
          lessonId: state.pathParameters['lessonId']!,
        ),
      ),
      GoRoute(
        path: '/courses/:id/exams',
        builder: (context, state) => ExamsListScreen(
          courseId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/courses/:id/exams/new',
        builder: (context, state) => AddEditExamScreen(
          courseId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/courses/:id/exams/:examId',
        builder: (context, state) => AddEditExamScreen(
          courseId: state.pathParameters['id']!,
          examId: state.pathParameters['examId'],
        ),
      ),
      GoRoute(
        path: '/courses/:id/exams/:examId/questions',
        builder: (context, state) => QuestionsScreen(
          courseId: state.pathParameters['id']!,
          examId: state.pathParameters['examId']!,
        ),
      ),
      GoRoute(
        path: '/courses/:id/exams/:examId/questions/new',
        builder: (context, state) => AddEditQuestionScreen(
          examId: state.pathParameters['examId']!,
        ),
      ),
      GoRoute(
        path: '/courses/:id/exams/:examId/questions/:questionId/edit',
        builder: (context, state) => AddEditQuestionScreen(
          examId: state.pathParameters['examId']!,
          questionId: state.pathParameters['questionId'],
        ),
      ),
      GoRoute(
        path: '/courses/:id/students',
        builder: (context, state) => StudentsListScreen(
          courseId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/courses/:id/certificates',
        builder: (context, state) => CertificatesScreen(
          courseId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/certificates/templates',
        builder: (context, state) => const CertificateTemplatesScreen(),
      ),
      GoRoute(
        path: '/certificates/templates/new',
        builder: (context, state) =>
            const CertificateTemplatesScreen(isEditing: true),
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
        path: '/profile/change-password',
        builder: (context, state) => const ChangePasswordScreen(),
      ),
      GoRoute(
        path: '/payments',
        builder: (context, state) => const PaymentsScreen(),
      ),
      GoRoute(
        path: '/payments/upload',
        builder: (context, state) => const UploadPaymentScreen(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
    ],
  );
}
