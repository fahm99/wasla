class LessonModel {
  final String id;
  final String title;
  final String type;
  final String? content;
  final String? fileUrl;
  final String? fileName;
  final int? fileSize;
  final int? duration; // duration in seconds (INTEGER in DB)
  final bool isFree;
  final int order;
  final String moduleId;
  final DateTime? createdAt;

  LessonModel({
    required this.id,
    required this.title,
    required this.type,
    this.content,
    this.fileUrl,
    this.fileName,
    this.fileSize,
    this.duration,
    this.isFree = false,
    required this.order,
    required this.moduleId,
    this.createdAt,
  });

  factory LessonModel.fromJson(Map<String, dynamic> json) {
    return LessonModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      type: json['type']?.toString() ?? 'TEXT',
      content: json['content']?.toString(),
      fileUrl: json['file_url']?.toString(),
      fileName: json['file_name']?.toString(),
      fileSize: (json['file_size'] as num?)?.toInt(),
      duration: (json['duration'] as num?)?.toInt(),
      isFree: json['is_free'] as bool? ?? false,
      order: (json['order'] as int?) ?? 0,
      moduleId: json['module_id']?.toString() ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type,
      'content': content,
      'file_url': fileUrl,
      'file_name': fileName,
      'file_size': fileSize,
      'duration': duration,
      'is_free': isFree,
      'order': order,
      'module_id': moduleId,
    };
  }

  LessonModel copyWith({
    String? title,
    String? type,
    String? content,
    String? fileUrl,
    String? fileName,
    int? fileSize,
    int? duration,
    bool? isFree,
    int? order,
  }) {
    return LessonModel(
      id: id,
      title: title ?? this.title,
      type: type ?? this.type,
      content: content ?? this.content,
      fileUrl: fileUrl ?? this.fileUrl,
      fileName: fileName ?? this.fileName,
      fileSize: fileSize ?? this.fileSize,
      duration: duration ?? this.duration,
      isFree: isFree ?? this.isFree,
      order: order ?? this.order,
      moduleId: moduleId,
      createdAt: createdAt,
    );
  }

  /// نص نوع الدرس بالعربية
  String get typeText {
    switch (type) {
      case 'VIDEO':
        return 'فيديو';
      case 'PDF':
        return 'PDF';
      case 'TEXT':
        return 'نص';
      case 'FILE':
        return 'ملف';
      case 'IMAGE':
        return 'صورة';
      case 'AUDIO':
        return 'صوتي';
      default:
        return type;
    }
  }

  String get formattedFileSize {
    if (fileSize == null) return '';
    if (fileSize! < 1024) return '$fileSize بايت';
    if (fileSize! < 1024 * 1024) {
      return '${(fileSize! / 1024).toStringAsFixed(1)} كيلوبايت';
    }
    if (fileSize! < 1024 * 1024 * 1024) {
      return '${(fileSize! / (1024 * 1024)).toStringAsFixed(1)} ميجابايت';
    }
    return '${(fileSize! / (1024 * 1024 * 1024)).toStringAsFixed(1)} جيجابايت';
  }
}
