class ExamModel {
  final String id;
  final String title;
  final String description;
  final int passingScore;
  final String? duration;
  final String courseId;
  final DateTime? createdAt;
  int? questionsCount;

  ExamModel({
    required this.id,
    required this.title,
    required this.description,
    required this.passingScore,
    this.duration,
    required this.courseId,
    this.createdAt,
    this.questionsCount,
  });

  factory ExamModel.fromJson(Map<String, dynamic> json) {
    return ExamModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      passingScore: json['passing_score'] ?? 60,
      duration: json['duration'],
      courseId: json['course_id'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      questionsCount: json['questions_count'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'passing_score': passingScore,
      'duration': duration,
      'course_id': courseId,
    };
  }

  ExamModel copyWith({
    String? title,
    String? description,
    int? passingScore,
    String? duration,
    int? questionsCount,
  }) {
    return ExamModel(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      passingScore: passingScore ?? this.passingScore,
      duration: duration ?? this.duration,
      courseId: courseId,
      createdAt: createdAt,
      questionsCount: questionsCount ?? this.questionsCount,
    );
  }
}
