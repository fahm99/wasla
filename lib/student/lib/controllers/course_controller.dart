import '../models/course_model.dart';
import '../models/module_model.dart';
import '../services/supabase_service.dart';

class CourseController {
  Future<List<CourseModel>> getPublishedCourses({
    String? search,
    String? category,
    String? level,
    double? minPrice,
    double? maxPrice,
    String? sortBy,
    int page = 1,
  }) async {
    return await SupabaseService.getPublishedCourses(
      search: search,
      category: category,
      level: level,
      minPrice: minPrice,
      maxPrice: maxPrice,
      sortBy: sortBy,
      page: page,
    );
  }

  Future<CourseModel> getCourseById(String courseId) async {
    return await SupabaseService.getCourseById(courseId);
  }

  Future<List<ModuleModel>> getCourseModules(String courseId) async {
    return await SupabaseService.getModulesByCourse(courseId);
  }

  Future<List<CourseModel>> getEnrolledCourses() async {
    return await SupabaseService.getEnrolledCourses();
  }
}
