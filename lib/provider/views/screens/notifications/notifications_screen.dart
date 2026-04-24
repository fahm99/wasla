import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/app_theme.dart';
import '../../../providers/notification_provider.dart';
import '../../../widgets/custom_app_bar.dart';
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

  Future<void> _loadNotifications() async {
    await context.read<NotificationProvider>().loadNotifications();
  }

  IconData _getNotifIcon(String type) {
    switch (type) {
      case 'تسجيل':
        return Icons.person_add;
      case 'شهادة':
        return Icons.workspace_premium;
      case 'دفعة':
        return Icons.payment;
      default:
        return Icons.notifications;
    }
  }

  Color _getNotifColor(String type) {
    switch (type) {
      case 'تسجيل':
        return AppTheme.greenSuccess;
      case 'شهادة':
        return AppTheme.yellowAccent;
      case 'دفعة':
        return AppTheme.blueInfo;
      default:
        return AppTheme.primaryDarkBlue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: CustomAppBar(
          title: 'الإشعارات',
          actions: [
            Consumer<NotificationProvider>(
              builder: (context, provider, child) {
                if (provider.unreadCount > 0) {
                  return TextButton(
                    onPressed: () => provider.markAllAsRead(),
                    child: const Text(
                      'قراءة الكل',
                      style: TextStyle(color: AppTheme.yellowAccent, fontSize: 13),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
        body: Consumer<NotificationProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const LoadingWidget(message: 'جاري تحميل الإشعارات...');
            }
            if (provider.notifications.isEmpty) {
              return const EmptyState(
                title: 'لا توجد إشعارات',
                message: 'ستظهر هنا الإشعارات الجديدة',
                icon: Icons.notifications_none,
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.notifications.length,
              itemBuilder: (context, index) {
                final notif = provider.notifications[index];
                return _buildNotificationItem(notif, provider);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildNotificationItem(dynamic notif, NotificationProvider provider) {
    final color = _getNotifColor(notif.type);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: notif.isRead ? Colors.white : AppTheme.primaryDarkBlue.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
        border: notif.isRead ? null : Border.all(color: AppTheme.primaryDarkBlue.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(child: Icon(_getNotifIcon(notif.type), color: color, size: 24)),
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
                        notif.title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: notif.isRead ? FontWeight.w500 : FontWeight.bold,
                          color: AppTheme.primaryDarkBlue,
                        ),
                      ),
                    ),
                    if (!notif.isRead)
                      Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppTheme.yellowAccent, shape: BoxShape.circle)),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  notif.message,
                  style: const TextStyle(fontSize: 13, color: AppTheme.darkGrayText, height: 1.4),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                if (notif.createdAt != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _formatDate(notif.createdAt),
                    style: const TextStyle(fontSize: 11, color: AppTheme.darkGrayText),
                  ),
                ],
              ],
            ),
          ),
          if (!notif.isRead)
            IconButton(
              icon: const Icon(Icons.done, size: 18, color: AppTheme.greenSuccess),
              onPressed: () => provider.markAsRead(notif.id),
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} - ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
