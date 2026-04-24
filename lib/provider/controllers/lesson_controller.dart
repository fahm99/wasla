import '../providers/lesson_provider.dart';

class LessonController {
  final LessonProvider _provider;

  LessonController(this._provider);

  Future<bool> validateAndCreate({
    required String title,
    required String type,
    required String moduleId,
    dynamic file,
    String? fileName,
    int? fileSize,
    String? duration,
  }) {
    if (title.trim().isEmpty) {
      _provider.setError('عنوان الدرس مطلوب');
      return Future.value(false);
    }
    return _provider
        .createLesson(
          title: title,
          type: type,
          moduleId: moduleId,
          order: _provider.lessons.length,
          file: file,
          fileName: fileName,
          fileSize: fileSize,
          duration: duration,
        )
        .then((v) => v != null);
  }
}
