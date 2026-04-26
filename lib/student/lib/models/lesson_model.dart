class LessonModel {
  final String id;
  final String title;
  final String type;
  final String? content;
  final String? fileUrl;
  final String? fileName;
  final int? fileSize;
  final int duration;
  final bool isFree;
  final int order;
  final String moduleId;
  bool isCompleted;
  double watchProgress;

  LessonModel({
    required this.id,
    required this.title,
    required this.type,
    this.content,
    this.fileUrl,
    this.fileName,
    this.fileSize,
    required this.duration,
    required this.isFree,
    required this.order,
    required this.moduleId,
    this.isCompleted = false,
    this.watchProgress = 0,
  });

  factory LessonModel.fromJson(Map<String, dynamic> json) {
    return LessonModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      type: json['type']?.toString() ?? 'TEXT',
      content: json['content'],
      fileUrl: json['file_url'],
      fileName: json['file_name'],
      fileSize: json['file_size'],
      duration: json['duration'] ?? 0,
      isFree: json['is_free'] ?? false,
      order: json['order'] ?? 0,
      moduleId: json['module_id'] ?? '',
      isCompleted: json['is_completed'] ?? false,
      watchProgress: (json['watch_progress'] is num)
          ? (json['watch_progress'] as num).toDouble()
          : 0,
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

  String get formattedDuration {
    final hours = duration ~/ 60;
    final minutes = duration % 60;
    if (hours > 0 && minutes > 0) {
      return '$hours:$minutes';
    } else if (hours > 0) {
      return '$hours:00';
    }
    return '$minutes:${(duration % 60).toString().padLeft(2, '0')}';
  }

  String get formattedFileSize {
    if (fileSize == null) return '';
    if (fileSize! < 1024) return '$fileSize B';
    if (fileSize! < 1024 * 1024) {
      return '${(fileSize! / 1024).toStringAsFixed(1)} KB';
    }
    if (fileSize! < 1024 * 1024 * 1024) {
      return '${(fileSize! / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(fileSize! / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  LessonModel copyWith({
    bool? isCompleted,
    double? watchProgress,
  }) {
    return LessonModel(
      id: id,
      title: title,
      type: type,
      content: content,
      fileUrl: fileUrl,
      fileName: fileName,
      fileSize: fileSize,
      duration: duration,
      isFree: isFree,
      order: order,
      moduleId: moduleId,
      isCompleted: isCompleted ?? this.isCompleted,
      watchProgress: watchProgress ?? this.watchProgress,
    );
  }
}
