class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String type;
  final String userId;
  final bool sentToAll;
  final DateTime createdAt;
  bool isRead;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.userId,
    required this.sentToAll,
    required this.createdAt,
    this.isRead = false,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      type: json['type'] ?? 'system',
      userId: json['user_id'] ?? '',
      sentToAll: json['sent_to_all'] ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      isRead: json['is_read'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type,
      'user_id': userId,
      'sent_to_all': sentToAll,
      'created_at': createdAt.toIso8601String(),
    };
  }

  String get timeAgo {
    final now = DateTime.now();
    final diff = now.difference(createdAt);
    if (diff.inDays > 0) return 'منذ ${diff.inDays} يوم';
    if (diff.inHours > 0) return 'منذ ${diff.inHours} ساعة';
    if (diff.inMinutes > 0) return 'منذ ${diff.inMinutes} دقيقة';
    return 'الآن';
  }

  String get typeLabel {
    switch (type) {
      case 'enrollment':
        return 'تسجيل';
      case 'exam':
        return 'اختبار';
      case 'certificate':
        return 'شهادة';
      case 'announcement':
        return 'إعلان';
      default:
        return 'نظام';
    }
  }
}
