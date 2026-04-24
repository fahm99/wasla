import '../models/course_model.dart';
import '../services/supabase_service.dart';

class SearchController {
  Future<List<CourseModel>> search({
    String? query,
    String? category,
    String? level,
    double? minPrice,
    double? maxPrice,
    String? sortBy,
  }) async {
    return await SupabaseService.getPublishedCourses(
      search: query,
      category: category,
      level: level,
      minPrice: minPrice,
      maxPrice: maxPrice,
      sortBy: sortBy,
    );
  }

  Future<List<String>> getCategories() async {
    try {
      return await SupabaseService.getCategories();
    } catch (_) {
      return [];
    }
  }
}
