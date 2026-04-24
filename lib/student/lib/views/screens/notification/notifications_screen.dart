import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../config/app_theme.dart';
import '../../../models/notification_model.dart';
import '../../../providers/notification_provider.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/loading_widget.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  void _loadNotifications() {
    context.read<NotificationProvider>().loadNotifications();
  }

  Future<void> _refreshNotifications() async {
    await context.read<NotificationProvider>().loadNotifications();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationProvider>();

    return Scaffold(
      backgroundColor: AppTheme.lightBg,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: AppTheme.white,
        elevation: 0,
        title: const Text(
          'الإشعارات',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppTheme.white,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          if (provider.notifications.any((n) => !n.isRead))
            TextButton(
              onPressed: () {
                provider.markAllAsRead();
              },
              child: const Text(
                'تحديد الكل كمقروء',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 12,
                  color: AppTheme.white,
                ),
              ),
            ),
        ],
      ),
      body: provider.isLoading
          ? const LoadingWidget(message: 'جاري تحميل الإشعارات...')
          : provider.notifications.isEmpty
              ? const EmptyState(
                  icon: Icons.notifications_none,
                  title: 'لا توجد إشعارات',
                  subtitle: 'ستظهر الإشعارات هنا',
                )
              : RefreshIndicator(
                  color: AppTheme.primaryBlue,
                  onRefresh: _refreshNotifications,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: provider.notifications.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      return _buildNotificationItem(
                          provider.notifications[index]);
                    },
                  ),
                ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildNotificationItem(NotificationModel notification) {
    final typeIcon = _getTypeIcon(notification.type);
    final typeColor = _getTypeColor(notification.type);

    return GestureDetector(
      onTap: () {
        if (!notification.isRead) {
          context.read<NotificationProvider>().markAsRead(notification.id);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: notification.isRead
              ? AppTheme.white
              : AppTheme.primaryBlue.withOpacity(0.05),
          borderRadius: BorderRadius.circular(14),
          border: notification.isRead
              ? null
              : Border.all(color: AppTheme.primaryBlue.withOpacity(0.2)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: typeColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(typeIcon, color: typeColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 14,
                            fontWeight: notification.isRead
                                ? FontWeight.w600
                                : FontWeight.w700,
                            color: AppTheme.darkText,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (!notification.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppTheme.primaryBlue,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.message,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 12,
                      color: AppTheme.greyText,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        notification.timeAgo,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 10,
                          color: AppTheme.greyText,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: typeColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          notification.typeLabel,
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 9,
                            color: typeColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'enrollment':
        return Icons.school;
      case 'exam':
        return Icons.quiz;
      case 'certificate':
        return Icons.verified;
      case 'announcement':
        return Icons.campaign;
      default:
        return Icons.info;
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'enrollment':
        return AppTheme.primaryBlue;
      case 'exam':
        return AppTheme.secondaryAmber;
      case 'certificate':
        return AppTheme.successGreen;
      case 'announcement':
        return AppTheme.infoBlue;
      default:
        return AppTheme.greyText;
    }
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: BottomNavigationBar(
          currentIndex: 3,
          onTap: (index) {
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
                break;
              case 4:
                context.go('/profile');
                break;
            }
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppTheme.primaryBlue,
          unselectedItemColor: AppTheme.greyText,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined), label: 'الرئيسية'),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: 'البحث'),
            BottomNavigationBarItem(
                icon: Icon(Icons.menu_book_outlined), label: 'دوراتي'),
            BottomNavigationBarItem(
                icon: Icon(Icons.notifications_outlined), label: 'الإشعارات'),
            BottomNavigationBarItem(
                icon: Icon(Icons.person_outline), label: 'حسابي'),
          ],
        ),
      ),
    );
  }
}
