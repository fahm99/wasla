import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/config/app_theme.dart';
import '../../provider/config/routes.dart';
import '../../provider/providers/auth_provider.dart';
import '../../provider/providers/course_provider.dart';
import '../../provider/providers/module_provider.dart';
import '../../provider/providers/lesson_provider.dart';
import '../../provider/providers/exam_provider.dart';
import '../../provider/providers/certificate_provider.dart';
import '../../provider/providers/notification_provider.dart';
import '../../provider/providers/payment_provider.dart';

class ProviderAppWrapper extends StatelessWidget {
  const ProviderAppWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
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
      child: MaterialApp.router(
        title: 'وصلة - مقدم الخدمة',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: AppRoutes.router,
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
