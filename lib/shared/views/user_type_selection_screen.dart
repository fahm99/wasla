import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'student_app_wrapper.dart';
import 'provider_app_wrapper.dart';
import 'admin_app_wrapper.dart';

class UserTypeSelectionScreen extends StatefulWidget {
  const UserTypeSelectionScreen({super.key});

  @override
  State<UserTypeSelectionScreen> createState() =>
      _UserTypeSelectionScreenState();
}

class _UserTypeSelectionScreenState extends State<UserTypeSelectionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF1E3A5F),
              const Color(0xFF1E3A5F).withOpacity(0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
              ),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  // Logo
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFC107),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFC107).withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'وصلة',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1E3A5F),
                        ),
                      ),
                    ),
                  )
                      .animate()
                      .scale(duration: 600.ms, curve: Curves.easeOutBack),
                  const SizedBox(height: 16),
                  const Text(
                    'منصة تعليمية متكاملة',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ).animate().fadeIn(delay: 300.ms, duration: 600.ms),
                  const SizedBox(height: 8),
                  Text(
                    'اختر نوع حسابك للمتابعة',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ).animate().fadeIn(delay: 500.ms, duration: 600.ms),
                  const SizedBox(height: 40),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildUserTypeCard(
                          context: context,
                          icon: Icons.school_rounded,
                          title: 'طالب',
                          description: 'تصفح الدورات والتسجيل فيها',
                          color: const Color(0xFF4CAF50),
                          onTap: () => _navigateToApp(context, 'student'),
                          delay: 700,
                        ),
                        const SizedBox(height: 16),
                        _buildUserTypeCard(
                          context: context,
                          icon: Icons.person_outline_rounded,
                          title: 'مقدم خدمة',
                          description: 'إنشاء وإدارة الدورات التعليمية',
                          color: const Color(0xFF2196F3),
                          onTap: () => _navigateToApp(context, 'provider'),
                          delay: 900,
                        ),
                        const SizedBox(height: 16),
                        _buildUserTypeCard(
                          context: context,
                          icon: Icons.admin_panel_settings_rounded,
                          title: 'مشرف',
                          description: 'إدارة المنصة والمستخدمين',
                          color: const Color(0xFFFF5722),
                          onTap: () => _navigateToApp(context, 'admin'),
                          delay: 1100,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'الإصدار 1.0.0',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                  ).animate().fadeIn(delay: 1300.ms, duration: 600.ms),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserTypeCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
    required int delay,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: color,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E3A5F),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 20,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .slideX(
          begin: 1,
          duration: 600.ms,
          delay: delay.ms,
          curve: Curves.easeOutCubic,
        )
        .fadeIn(duration: 600.ms, delay: delay.ms);
  }

  void _navigateToApp(BuildContext context, String userType) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) {
          switch (userType) {
            case 'student':
              return const StudentAppWrapper();
            case 'provider':
              return const ProviderAppWrapper();
            case 'admin':
              return const AdminAppWrapper();
            default:
              return const UserTypeSelectionScreen();
          }
        },
      ),
    );
  }
}
