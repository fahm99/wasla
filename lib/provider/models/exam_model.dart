class ExamModel {
  final String id;
  final String title;
  final String description;
  final int passingScore;
  final int duration;
  final int maxAttempts;
  final String courseId;
  final DateTime? createdAt;
  int? questionsCount;

  ExamModel({
    required this.id,
    required this.title,
    required this.description,
    required this.passingScore,
    this.duration = 30,
    this.maxAttempts = 3,
    required this.courseId,
    this.createdAt,
    this.questionsCount,
  });

  factory ExamModel.fromJson(Map<String, dynamic> json) {
    return ExamModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      passingScore: (json['passing_score'] as int?) ?? 60,
      duration: (json['duration'] as int?) ?? 30,
      maxAttempts: (json['max_attempts'] as int?) ?? 3,
      courseId: json['course_id']?.toString() ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      questionsCount: json['questions_count'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'passing_score': passingScore,
      'duration': duration,
      'max_attempts': maxAttempts,
      'course_id': courseId,
    };
  }

  ExamModel copyWith({
    String? title,
    String? description,
    int? passingScore,
    int? duration,
    int? maxAttempts,
    int? questionsCount,
  }) {
    return ExamModel(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      passingScore: passingScore ?? this.passingScore,
      duration: duration ?? this.duration,
      maxAttempts: maxAttempts ?? this.maxAttempts,
      courseId: courseId,
      createdAt: createdAt,
      questionsCount: questionsCount ?? this.questionsCount,
    );
  }
}
