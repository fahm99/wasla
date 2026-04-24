class EnrollmentModel {
  final String id;
  final double progress;
  final DateTime enrolledAt;
  final DateTime? completedAt;
  final DateTime? lastAccessedAt;
  final String studentId;
  final String courseId;
  final String? courseTitle;
  final String? courseImage;
  final String? courseLevel;
  final String? providerName;
  final int? completedLessons;
  final int? totalLessons;

  EnrollmentModel({
    required this.id,
    required this.progress,
    required this.enrolledAt,
    this.completedAt,
    this.lastAccessedAt,
    required this.studentId,
    required this.courseId,
    this.courseTitle,
    this.courseImage,
    this.courseLevel,
    this.providerName,
    this.completedLessons,
    this.totalLessons,
  });

  factory EnrollmentModel.fromJson(Map<String, dynamic> json) {
    return EnrollmentModel(
      id: json['id'] ?? '',
      progress: (json['progress'] is int) ? (json['progress'] as int).toDouble() : (json['progress'] ?? 0.0).toDouble(),
      enrolledAt: json['enrolled_at'] != null ? DateTime.parse(json['enrolled_at']) : DateTime.now(),
      completedAt: json['completed_at'] != null ? DateTime.parse(json['completed_at']) : null,
      lastAccessedAt: json['last_accessed_at'] != null ? DateTime.parse(json['last_accessed_at']) : null,
      studentId: json['student_id'] ?? '',
      courseId: json['course_id'] ?? '',
      courseTitle: json['course_title'],
      courseImage: json['course_image'],
      courseLevel: json['course_level'],
      providerName: json['provider_name'],
      completedLessons: json['completed_lessons'],
      totalLessons: json['total_lessons'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'progress': progress,
      'enrolled_at': enrolledAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'last_accessed_at': lastAccessedAt?.toIso8601String(),
      'student_id': studentId,
      'course_id': courseId,
    };
  }

  bool get isCompleted => completedAt != null;

  String get progressPercent => '${progress.toStringAsFixed(0)}%';
}
