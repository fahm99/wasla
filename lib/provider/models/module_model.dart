class ModuleModel {
  final String id;
  final String title;
  final int order;
  final String courseId;
  final DateTime? createdAt;
  int? lessonsCount;

  ModuleModel({
    required this.id,
    required this.title,
    required this.order,
    required this.courseId,
    this.createdAt,
    this.lessonsCount,
  });

  factory ModuleModel.fromJson(Map<String, dynamic> json) {
    return ModuleModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      order: json['order'] ?? 0,
      courseId: json['course_id'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      lessonsCount: json['lessons_count'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'order': order,
      'course_id': courseId,
    };
  }

  ModuleModel copyWith({
    String? title,
    int? order,
    int? lessonsCount,
  }) {
    return ModuleModel(
      id: id,
      title: title ?? this.title,
      order: order ?? this.order,
      courseId: courseId,
      createdAt: createdAt,
      lessonsCount: lessonsCount ?? this.lessonsCount,
    );
  }
}
