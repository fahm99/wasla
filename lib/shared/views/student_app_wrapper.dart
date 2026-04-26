import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wasla_provider/student/lib/config/app_theme.dart';
import 'package:wasla_provider/student/lib/config/routes.dart';
import 'package:wasla_provider/student/lib/providers/auth_provider.dart';
import 'package:wasla_provider/student/lib/providers/course_provider.dart';
import 'package:wasla_provider/student/lib/providers/enrollment_provider.dart';
import 'package:wasla_provider/student/lib/providers/exam_provider.dart';
import 'package:wasla_provider/student/lib/providers/certificate_provider.dart';
import 'package:wasla_provider/student/lib/providers/notification_provider.dart';
import 'package:wasla_provider/student/lib/providers/search_provider.dart';

class StudentAppWrapper extends StatelessWidget {
  const StudentAppWrapper({super.key});

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
        title: 'وصلة - الطالب',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: AppRouter.router,
        builder: (context, child) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: child ?? const SizedBox(),
          );
        },
      ),
    );
  }
}
