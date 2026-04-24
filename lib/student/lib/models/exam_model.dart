import 'question_model.dart';

class ExamModel {
  final String id;
  final String title;
  final String description;
  final double passingScore;
  final int duration;
  final int maxAttempts;
  final String courseId;
  final List<QuestionModel> questions;
  final int? attemptsUsed;

  ExamModel({
    required this.id,
    required this.title,
    required this.description,
    required this.passingScore,
    required this.duration,
    required this.maxAttempts,
    required this.courseId,
    this.questions = const [],
    this.attemptsUsed,
  });

  factory ExamModel.fromJson(Map<String, dynamic> json) {
    return ExamModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      passingScore: (json['passing_score'] is int)
          ? (json['passing_score'] as int).toDouble()
          : (json['passing_score'] ?? 60.0).toDouble(),
      duration: json['duration'] ?? 30,
      maxAttempts: json['max_attempts'] ?? 3,
      courseId: json['course_id'] ?? '',
      questions: json['questions'] != null
          ? (json['questions'] as List)
              .map((q) => QuestionModel.fromJson(q))
              .toList()
          : [],
      attemptsUsed: json['attempts_used'],
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

  int get totalQuestions => questions.length;

  double get totalPoints =>
      questions.fold(0.0, (sum, q) => sum + q.points);

  bool get canAttempt =>
      maxAttempts == 0 || (attemptsUsed ?? 0) < maxAttempts;

  int get remainingAttempts =>
      maxAttempts == 0 ? 999 : maxAttempts - (attemptsUsed ?? 0);

  String get formattedDuration {
    final hours = duration ~/ 60;
    final minutes = duration % 60;
    if (hours > 0 && minutes > 0) return '$hours ساعة و $minutes دقيقة';
    if (hours > 0) return '$hours ساعة';
    return '$minutes دقيقة';
  }
}
