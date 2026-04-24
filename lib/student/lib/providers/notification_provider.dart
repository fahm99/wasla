import 'package:flutter/foundation.dart';
import '../models/notification_model.dart';
import '../services/supabase_service.dart';

class NotificationProvider with ChangeNotifier {
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  String? _error;
  int _unreadCount = 0;

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get unreadCount => _unreadCount;

  Future<void> loadNotifications() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _notifications = await SupabaseService.getMyNotifications();
      _unreadCount = _notifications.where((n) => !n.isRead).length;
      _error = null;
    } catch (e) {
      _error = 'خطأ في تحميل الإشعارات';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadUnreadCount() async {
    try {
      _unreadCount = await SupabaseService.getUnreadCount();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await SupabaseService.markNotificationRead(notificationId);
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(isRead: true);
        _unreadCount = _notifications.where((n) => !n.isRead).length;
        notifyListeners();
      }
    } catch (e) {
      _error = 'خطأ في تحديث الإشعار';
      notifyListeners();
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await SupabaseService.markAllNotificationsRead();
      for (var n in _notifications) {
        n = n.copyWith(isRead: true);
      }
      _unreadCount = 0;
      notifyListeners();
    } catch (e) {
      _error = 'خطأ في تحديث الإشعارات';
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

extension NotificationExtension on NotificationModel {
  NotificationModel copyWith({bool? isRead}) {
    return NotificationModel(
      id: id,
      title: title,
      message: message,
      type: type,
      userId: userId,
      sentToAll: sentToAll,
      createdAt: createdAt,
      isRead: isRead ?? this.isRead,
    );
  }
}
