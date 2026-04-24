import '../models/enrollment_model.dart';
import '../services/supabase_service.dart';

class EnrollmentController {
  Future<void> enroll(String courseId) async {
    await SupabaseService.enrollInCourse(courseId);
  }

  Future<EnrollmentModel?> getEnrollment(String courseId) async {
    return await SupabaseService.getEnrollment(courseId);
  }

  Future<List<EnrollmentModel>> getMyEnrollments() async {
    return await SupabaseService.getMyEnrollments();
  }

  Future<double> getProgress(String courseId) async {
    return await SupabaseService.getCourseProgress(courseId);
  }
}
