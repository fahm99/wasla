import '../providers/exam_provider.dart';

class ExamController {
  final ExamProvider _provider;

  ExamController(this._provider);

  Future<bool> validateAndCreate({
    required String title,
    required String description,
    required int passingScore,
    required String courseId,
    int? duration,
  }) {
    if (title.trim().isEmpty) {
      _provider.setError('عنوان الامتحان مطلوب');
      return Future.value(false);
    }
    if (passingScore < 0 || passingScore > 100) {
      _provider.setError('درجة النجاح يجب أن تكون بين 0 و 100');
      return Future.value(false);
    }
    return _provider
        .createExam(
          title: title,
          description: description,
          passingScore: passingScore,
          courseId: courseId,
          duration: duration ?? 30,
        )
        .then((v) => v != null);
  }
}
