import '../providers/notifications_provider.dart';

class NotificationsController {
  final NotificationsProvider provider;

  NotificationsController(this.provider);

  Future<void> loadNotifications() async {
    await provider.loadNotifications();
  }

  Future<bool> sendNotification({
    required String title,
    required String message,
    required String targetType,
    String? targetRoles,
  }) async {
    if (title.trim().isEmpty || message.trim().isEmpty) {
      return false;
    }
    return await provider.sendNotification(
      title: title,
      message: message,
      targetType: targetType,
      targetRoles: targetRoles,
    );
  }

  void dispose() {}
}
