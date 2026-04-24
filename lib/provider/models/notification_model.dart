class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String type;
  final String? userId;
  final bool? sentToAll;
  final bool isRead;
  final DateTime? createdAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    this.userId,
    this.sentToAll,
    this.isRead = false,
    this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      type: json['type'] ?? 'نظام',
      userId: json['user_id'],
      sentToAll: json['sent_to_all'],
      isRead: json['is_read'] ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
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
      'is_read': isRead,
    };
  }

  NotificationModel copyWith({
    bool? isRead,
  }) {
    return NotificationModel(
      id: id,
      title: title,
      message: message,
      type: type,
      userId: userId,
      sentToAll: sentToAll,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
    );
  }
}
