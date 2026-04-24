import 'package:flutter/foundation.dart';
import '../models/notification_model.dart';
import '../services/supabase_service.dart';

class NotificationsProvider with ChangeNotifier {
  final SupabaseService _supabaseService;

  NotificationsProvider(this._supabaseService);

  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  bool _isSending = false;
  String? _errorMessage;
  int _unreadCount = 0;

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  bool get isSending => _isSending;
  String? get errorMessage => _errorMessage;
  int get unreadCount => _unreadCount;

  Future<void> loadNotifications() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _notifications = await _supabaseService.getAllNotifications();
      _unreadCount = _notifications.length;
    } catch (e) {
      _errorMessage = 'حدث خطأ في تحميل الإشعارات';
      _notifications = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> sendNotification({
    required String title,
    required String message,
    required String targetType,
    String? targetRoles,
  }) async {
    _isSending = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final notification = await _supabaseService.sendNotification(
        title: title,
        message: message,
        targetType: targetType,
        targetRoles: targetRoles,
      );

      _notifications.insert(0, notification);
      _unreadCount = _notifications.length;

      _isSending = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'حدث خطأ في إرسال الإشعار';
      _isSending = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
