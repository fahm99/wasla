import '../services/supabase_service.dart';
import '../models/user_model.dart';

class StudentController {
  final SupabaseService _supabaseService = SupabaseService();

  Future<List<UserModel>> getStudentsByCourse(String courseId) async {
    return await _supabaseService.getStudentsByCourse(courseId);
  }
}
