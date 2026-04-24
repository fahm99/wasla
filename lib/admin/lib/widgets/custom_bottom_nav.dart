import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import 'package:go_router/go_router.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        decoration: const BoxDecoration(
          color: AppTheme.white,
          boxShadow: [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) {
            switch (index) {
              case 0:
                context.go('/dashboard');
                break;
              case 1:
                context.go('/accounts');
                break;
              case 2:
                context.go('/payments');
                break;
              case 3:
                context.go('/notifications');
                break;
              case 4:
                context.go('/reports');
                break;
              case 5:
                context.go('/profile');
                break;
            }
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppTheme.primaryDarkBlue,
          unselectedItemColor: AppTheme.darkGrayText,
          selectedFontSize: 10,
          unselectedFontSize: 10,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'الرئيسية',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people_outline),
              activeIcon: Icon(Icons.people),
              label: 'الحسابات',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.credit_card_outlined),
              activeIcon: Icon(Icons.credit_card),
              label: 'المدفوعات',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications_outlined),
              activeIcon: Icon(Icons.notifications),
              label: 'الإشعارات',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_outlined),
              activeIcon: Icon(Icons.bar_chart),
              label: 'التقارير',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'البروفايل',
            ),
          ],
        ),
      ),
    );
  }
}
