import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../config/app_theme.dart';
import '../providers/notification_provider.dart';

class CustomBottomNav extends StatefulWidget {
  final int currentIndex;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
  });

  @override
  State<CustomBottomNav> createState() => _CustomBottomNavState();
}

class _CustomBottomNavState extends State<CustomBottomNav> {
  @override
  Widget build(BuildContext context) {
    final notificationProvider = context.watch<NotificationProvider>();

    return BottomNavigationBar(
      currentIndex: widget.currentIndex,
      onTap: (index) => _onTap(index),
      type: BottomNavigationBarType.fixed,
      backgroundColor: AppTheme.white,
      selectedItemColor: AppTheme.primaryBlue,
      unselectedItemColor: AppTheme.greyText,
      selectedLabelStyle: const TextStyle(
        fontFamily: 'Cairo',
        fontSize: 11,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: const TextStyle(
        fontFamily: 'Cairo',
        fontSize: 11,
      ),
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.home_outlined),
          activeIcon: const Icon(Icons.home),
          label: 'الرئيسية',
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.search),
          activeIcon: const Icon(Icons.search),
          label: 'البحث',
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.menu_book_outlined),
          activeIcon: const Icon(Icons.menu_book),
          label: 'دوراتي',
        ),
        BottomNavigationBarItem(
          icon: Badge(
            isLabelVisible: notificationProvider.unreadCount > 0,
            label: Text(notificationProvider.unreadCount > 9
                ? '9+'
                : '${notificationProvider.unreadCount}'),
            child: const Icon(Icons.notifications_outlined),
          ),
          activeIcon: Badge(
            isLabelVisible: notificationProvider.unreadCount > 0,
            label: Text(notificationProvider.unreadCount > 9
                ? '9+'
                : '${notificationProvider.unreadCount}'),
            child: const Icon(Icons.notifications),
          ),
          label: 'الإشعارات',
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.person_outline),
          activeIcon: const Icon(Icons.person),
          label: 'حسابي',
        ),
      ],
    );
  }

  void _onTap(int index) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/search');
        break;
      case 2:
        context.go('/my-courses');
        break;
      case 3:
        context.go('/notifications');
        break;
      case 4:
        context.go('/profile');
        break;
    }
  }
}
