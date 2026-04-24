import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../config/app_theme.dart';
import '../../../config/constants.dart';
import '../../../providers/notifications_provider.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/custom_bottom_nav.dart';
import '../../../widgets/loading_widget.dart';
import '../../../widgets/empty_state.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NotificationsProvider>(context, listen: false)
          .loadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGrayBg,
      appBar: CustomAppBar(
        title: Constants.titleNotifications,
        showBack: false,
        backgroundColor: AppTheme.primaryDarkBlue,
        actions: [
          IconButton(
            icon: const Icon(Icons.send, color: AppTheme.white),
            onPressed: () => context.push('/notifications/send'),
            tooltip: 'إرسال إشعار',
          ),
        ],
      ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => context.push('/notifications/send'),
          backgroundColor: AppTheme.primaryDarkBlue,
          child: const Icon(Icons.add, color: AppTheme.white),
        ),
        body: Consumer<NotificationsProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const LoadingWidget(itemCount: 5);
            }

            if (provider.notifications.isEmpty) {
              return EmptyState(
                icon: Icons.notifications_outlined,
                title: 'لا توجد إشعارات',
                subtitle: 'لم يتم إرسال أي إشعارات بعد',
                onAction: () => context.push('/notifications/send'),
                actionText: 'إرسال إشعار جديد',
              );
            }

            return RefreshIndicator(
              onRefresh: () => provider.loadNotifications(),
              color: AppTheme.primaryDarkBlue,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                itemCount: provider.notifications.length,
                itemBuilder: (context, index) {
                  final notification = provider.notifications[index];
                  return _buildNotificationCard(notification);
                },
              ),
            );
          },
        ),
        bottomNavigationBar: const CustomBottomNav(currentIndex: 3),
      
    );
  }

  Widget _buildNotificationCard(notification) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryDarkBlue.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.notifications,
                    color: AppTheme.primaryDarkBlue,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification.title,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryDarkBlue,
                        ),
                      ),
                    ],
                  ),
                ),
                if (notification.createdAt != null)
                  Text(
                    DateFormat('dd/MM HH:mm').format(notification.createdAt!),
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 10,
                      color: AppTheme.darkGrayText,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              notification.body,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 13,
                color: AppTheme.darkGrayText,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.blueInfo.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.people,
                          size: 12, color: AppTheme.blueInfo),
                      const SizedBox(width: 4),
                      Text(
                        notification.targetText,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.blueInfo,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
