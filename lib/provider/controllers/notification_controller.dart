import '../providers/notification_provider.dart';

class NotificationController {
  final NotificationProvider _provider;

  NotificationController(this._provider);

  Future<void> load() => _provider.loadNotifications();

  Future<void> markAsRead(String id) => _provider.markAsRead(id);

  Future<void> markAllAsRead() => _provider.markAllAsRead();
}
