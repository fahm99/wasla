import '../providers/module_provider.dart';

class ModuleController {
  final ModuleProvider _provider;

  ModuleController(this._provider);

  Future<bool> validateAndCreate({
    required String title,
    required String courseId,
  }) {
    if (title.trim().isEmpty) {
      _provider.setError('عنوان الوحدة مطلوب');
      return Future.value(false);
    }
    return _provider
        .createModule(
          title: title,
          courseId: courseId,
          order: _provider.modules.length,
        )
        .then((v) => v != null);
  }
}
