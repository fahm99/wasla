import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../services/supabase_service.dart';

class NotificationProvider with ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();

  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  String? _error;

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  Future<void> loadNotifications() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _notifications = await _supabaseService.getMyNotifications();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _supabaseService.markNotificationAsRead(notificationId);
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(isRead: true);
      }
      notifyListeners();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  Future<void> markAllAsRead() async {
    for (final n in _notifications.where((n) => !n.isRead)) {
      await markAsRead(n.id);
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
