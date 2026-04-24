import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../config/app_theme.dart';
import '../providers/auth_provider.dart';

class CustomDrawer extends StatelessWidget {
  final String? currentRoute;

  const CustomDrawer({super.key, this.currentRoute});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Drawer(
        child: Container(
          color: AppTheme.primaryDarkBlue,
          child: SafeArea(
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: Color(0xFF0A0F35),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: AppTheme.yellowAccent,
                        backgroundImage: user?.avatar != null
                            ? NetworkImage(user!.avatar!)
                            : null,
                        child: user?.avatar == null
                            ? Text(
                                user?.name.isNotEmpty == true
                                    ? user!.name[0]
                                    : 'م',
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryDarkBlue,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        user?.name ?? 'مزود الخدمة',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.email ?? '',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      _buildMenuItem(
                        context,
                        icon: Icons.dashboard_outlined,
                        title: 'لوحة التحكم',
                        route: '/dashboard',
                        currentRoute: currentRoute,
                      ),
                      _buildMenuItem(
                        context,
                        icon: Icons.school_outlined,
                        title: 'الدورات',
                        route: '/courses',
                        currentRoute: currentRoute,
                      ),
                      _buildMenuItem(
                        context,
                        icon: Icons.people_outline,
                        title: 'الطلاب',
                        route: '/courses',
                        currentRoute: currentRoute,
                        subtitle: 'ضمن كل دورة',
                      ),
                      _buildMenuItem(
                        context,
                        icon: Icons.emoji_events_outlined,
                        title: 'الشهادات',
                        route: '/certificates/templates',
                        currentRoute: currentRoute,
                      ),
                      _buildMenuItem(
                        context,
                        icon: Icons.payment_outlined,
                        title: 'المدفوعات',
                        route: '/payments',
                        currentRoute: currentRoute,
                      ),
                      _buildMenuItem(
                        context,
                        icon: Icons.notifications_outlined,
                        title: 'الإشعارات',
                        route: '/notifications',
                        currentRoute: currentRoute,
                      ),
                      _buildMenuItem(
                        context,
                        icon: Icons.person_outline,
                        title: 'الملف الشخصي',
                        route: '/profile',
                        currentRoute: currentRoute,
                      ),
                    ],
                  ),
                ),
                // Logout
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: ListTile(
                    leading: const Icon(Icons.logout, color: AppTheme.redDanger),
                    title: const Text(
                      'تسجيل الخروج',
                      style: TextStyle(color: AppTheme.redDanger),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    onTap: () {
                      authProvider.signOut();
                      context.go('/login');
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String route,
    String? currentRoute,
    String? subtitle,
  }) {
    final isActive = currentRoute != null && currentRoute.startsWith(route);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isActive
                ? AppTheme.yellowAccent
                : Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: isActive ? AppTheme.primaryDarkBlue : Colors.white,
            size: 22,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isActive ? AppTheme.yellowAccent : Colors.white,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            fontSize: 15,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 11,
                ),
              )
            : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: isActive
              ? const BorderSide(color: AppTheme.yellowAccent, width: 1)
              : BorderSide.none,
        ),
        onTap: () {
          Navigator.pop(context);
          context.go(route);
        },
      ),
    );
  }
}
