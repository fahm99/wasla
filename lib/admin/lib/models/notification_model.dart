class NotificationModel {
  final String id;
  final String title;
  final String body;
  final bool sentToAll;
  final String? targetRoles;
  final int? recipientCount;
  final String? senderId;
  final String? senderName;
  final DateTime? createdAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    this.sentToAll = false,
    this.targetRoles,
    this.recipientCount,
    this.senderId,
    this.senderName,
    this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      body: json['message']?.toString() ?? json['body']?.toString() ?? '',
      sentToAll: json['sent_to_all'] == true || json['sent_to_all'] == 'true',
      targetRoles: json['target_roles']?.toString(),
      recipientCount: json['recipient_count'] as int?,
      senderId: json['sender_id']?.toString(),
      senderName: json['sender_name']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': body,
      'sent_to_all': sentToAll,
      'target_roles': targetRoles,
      'sender_id': senderId,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  String get targetText {
    if (sentToAll) return 'الجميع';
    if (targetRoles != null) {
      switch (targetRoles) {
        case 'PROVIDER':
          return 'جميع المقدمين';
        case 'STUDENT':
          return 'جميع الطلاب';
        default:
          return targetRoles!;
      }
    }
    return 'محدد';
  }
}
