import '../providers/course_provider.dart';

class CourseController {
  final CourseProvider _provider;

  CourseController(this._provider);

  Future<bool> validateAndCreate({
    required String title,
    required String description,
    required double price,
    required String level,
    required String category,
    dynamic imageFile,
  }) {
    if (title.trim().isEmpty) {
      _provider.setError('عنوان الدورة مطلوب');
      return Future.value(false);
    }
    if (description.trim().isEmpty) {
      _provider.setError('وصف الدورة مطلوب');
      return Future.value(false);
    }
    if (price < 0) {
      _provider.setError('السعر يجب أن يكون صفر أو أكثر');
      return Future.value(false);
    }
    return _provider
        .createCourse(
          title: title,
          description: description,
          price: price,
          level: level,
          category: category,
          imageFile: imageFile,
        )
        .then((v) => v != null);
  }

  Future<bool> validateAndUpdate({
    required String courseId,
    required String title,
    required String description,
    required double price,
    required String level,
    required String category,
    dynamic imageFile,
  }) {
    if (title.trim().isEmpty) {
      _provider.setError('عنوان الدورة مطلوب');
      return Future.value(false);
    }
    if (description.trim().isEmpty) {
      _provider.setError('وصف الدورة مطلوب');
      return Future.value(false);
    }
    return _provider.updateCourse(
      courseId: courseId,
      title: title,
      description: description,
      price: price,
      level: level,
      category: category,
      imageFile: imageFile,
    );
  }
}
