import '../models/exam_model.dart';
import '../services/supabase_service.dart';

class ExamController {
  Future<List<ExamModel>> getExamsByCourse(String courseId) async {
    return await SupabaseService.getExamsByCourse(courseId);
  }

  Future<ExamModel> getExamById(String examId) async {
    return await SupabaseService.getExamById(examId);
  }

  Future<String> submitExam({
    required String examId,
    required Map<String, dynamic> studentAnswers,
    required int timeSpent,
  }) async {
    return await SupabaseService.submitExamAttempt(
      examId: examId,
      studentAnswers: studentAnswers,
      timeSpent: timeSpent,
    );
  }

  Future<Map<String, dynamic>> getExamResult(String attemptId) async {
    return await SupabaseService.getExamAttempt(attemptId);
  }

  Future<int> getAttemptsCount(String examId) async {
    return await SupabaseService.getExamAttemptsCount(examId);
  }
}
