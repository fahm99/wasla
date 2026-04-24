import '../providers/courses_provider.dart';

class CoursesController {
  final CoursesProvider provider;

  CoursesController(this.provider);

  Future<void> loadCourses({String filter = ''}) async {
    provider.setFilter(filter);
  }

  Future<void> search(String query) async {
    provider.searchCourses(query);
  }

  Future<void> getCourseDetail(String id) async {
    await provider.getCourseDetail(id);
  }

  Future<bool> publishCourse(String id) async {
    return await provider.updateCourseStatus(id, 'PUBLISHED');
  }

  Future<bool> archiveCourse(String id) async {
    return await provider.updateCourseStatus(id, 'ARCHIVED');
  }

  void dispose() {}
}
