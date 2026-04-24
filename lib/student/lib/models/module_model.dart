import 'lesson_model.dart';

class ModuleModel {
  final String id;
  final String title;
  final int order;
  final String courseId;
  final List<LessonModel> lessons;

  ModuleModel({
    required this.id,
    required this.title,
    required this.order,
    required this.courseId,
    this.lessons = const [],
  });

  factory ModuleModel.fromJson(Map<String, dynamic> json) {
    return ModuleModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      order: json['order'] ?? 0,
      courseId: json['course_id'] ?? '',
      lessons: json['lessons'] != null
          ? (json['lessons'] as List).map((l) => LessonModel.fromJson(l)).toList()
          : [],
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

  int get totalLessons => lessons.length;

  int get completedLessons => lessons.where((l) => l.isCompleted).length;

  Duration get totalDuration {
    int totalMinutes = 0;
    for (final lesson in lessons) {
      totalMinutes += lesson.duration;
    }
    return Duration(minutes: totalMinutes);
  }

  double get progress => totalLessons > 0 ? completedLessons / totalLessons : 0;
}
