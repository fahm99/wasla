import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../config/app_theme.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  context,
                  icon: Icons.dashboard_outlined,
                  activeIcon: Icons.dashboard,
                  label: 'الرئيسية',
                  index: 0,
                  route: '/dashboard',
                ),
                _buildNavItem(
                  context,
                  icon: Icons.school_outlined,
                  activeIcon: Icons.school,
                  label: 'الدورات',
                  index: 1,
                  route: '/courses',
                ),
                _buildNavItem(
                  context,
                  icon: Icons.notifications_outlined,
                  activeIcon: Icons.notifications,
                  label: 'الإشعارات',
                  index: 2,
                  route: '/notifications',
                ),
                _buildNavItem(
                  context,
                  icon: Icons.person_outline,
                  activeIcon: Icons.person,
                  label: 'حسابي',
                  index: 3,
                  route: '/profile',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
    required String route,
  }) {
    final isActive = currentIndex == index;
    return GestureDetector(
      onTap: () {
        if (currentIndex != index) {
          context.go(route);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? AppTheme.primaryDarkBlue.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive ? AppTheme.primaryDarkBlue : AppTheme.darkGrayText,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? AppTheme.primaryDarkBlue : AppTheme.darkGrayText,
                fontSize: 11,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
