class LessonModel {
  final String id;
  final String title;
  final String type;
  final String? content;
  final String? fileUrl;
  final String? fileName;
  final int? fileSize;
  final String? duration;
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
    required this.order,
    required this.moduleId,
    this.createdAt,
  });

  factory LessonModel.fromJson(Map<String, dynamic> json) {
    return LessonModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      type: json['type'] ?? 'فيديو',
      content: json['content'],
      fileUrl: json['file_url'],
      fileName: json['file_name'],
      fileSize: json['file_size'],
      duration: json['duration'],
      order: json['order'] ?? 0,
      moduleId: json['module_id'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
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
    String? duration,
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
      order: order ?? this.order,
      moduleId: moduleId,
      createdAt: createdAt,
    );
  }

  String get formattedFileSize {
    if (fileSize == null) return '';
    if (fileSize! < 1024) return '$fileSize بايت';
    if (fileSize! < 1024 * 1024) return '${(fileSize! / 1024).toStringAsFixed(1)} كيلوبايت';
    if (fileSize! < 1024 * 1024 * 1024) {
      return '${(fileSize! / (1024 * 1024)).toStringAsFixed(1)} ميجابايت';
    }
    return '${(fileSize! / (1024 * 1024 * 1024)).toStringAsFixed(1)} جيجابايت';
  }
}
