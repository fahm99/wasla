import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;
import '../models/user_model.dart';
import '../models/course_model.dart';
import '../models/module_model.dart';
import '../models/lesson_model.dart';
import '../models/exam_model.dart';
import '../models/enrollment_model.dart';
import '../models/certificate_model.dart';
import '../models/notification_model.dart';
import '../models/question_model.dart';
import '../models/answer_model.dart';
import '../models/rating_model.dart';

class SupabaseService {
  static final SupabaseClient _client = Supabase.instance.client;

  // ==================== AUTH ====================

  static Future<UserModel> signUp({
    required String name,
    required String email,
    required String password,
    String? phone,
    String? gender,
  }) async {
    final authResponse = await _client.auth.signUp(
      email: email,
      password: password,
      data: {
        'name': name,
        'role': 'STUDENT',
        'phone': phone ?? '',
        'gender': gender ?? '',
      },
    );

    if (authResponse.user == null) {
      throw Exception('فشل إنشاء الحساب');
    }

    // The handle_new_user trigger creates the profile automatically.
    // We return a local model; the real profile will be fetched on next login.
    return UserModel(
      id: authResponse.user!.id,
      name: name,
      email: email,
      phone: phone,
      gender: gender,
      role: 'STUDENT',
      status: 'PENDING',
    );
  }

  static Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    final authResponse = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (authResponse.user == null) {
      throw Exception('فشل تسجيل الدخول');
    }

    final profile = await _client
        .from('profiles')
        .select()
        .eq('id', authResponse.user!.id)
        .single();

    return UserModel.fromJson(
        {...profile, 'email': authResponse.user!.email ?? email});
  }

  static Future<void> signOut() async {
    await _client.auth.signOut();
  }

  static Future<UserModel?> getCurrentUser() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;

    try {
      final profile =
          await _client.from('profiles').select().eq('id', user.id).single();
      return UserModel.fromJson(profile);
    } catch (_) {
      return UserModel(
        id: user.id,
        name: user.userMetadata?['name'] ?? '',
        email: user.email ?? '',
        role: 'STUDENT',
      );
    }
  }

  static Future<void> resetPassword(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  // ==================== COURSES ====================

  static Future<List<CourseModel>> getPublishedCourses({
    String? search,
    String? category,
    String? level,
    double? minPrice,
    double? maxPrice,
    String? sortBy,
    int page = 1,
    int limit = 20,
  }) async {
    dynamic query = _client
        .from('courses')
        .select('*, provider:profiles!courses_provider_id_fkey(name, avatar)')
        .eq('status', 'PUBLISHED');

    if (search != null && search.isNotEmpty) {
      query = query.or(
          'title.ilike.%$search%,description.ilike.%$search%,short_description.ilike.%$search%');
    }

    if (category != null && category.isNotEmpty) {
      query = query.eq('category', category);
    }

    if (level != null && level.isNotEmpty) {
      query = query.eq('level', level);
    }

    if (minPrice != null) {
      query = query.gte('price', minPrice);
    }

    if (maxPrice != null) {
      query = query.lte('price', maxPrice);
    }

    switch (sortBy) {
      case 'newest':
        query = query.order('created_at', ascending: false);
        break;
      case 'popular':
        query = query.order('enrollments_count', ascending: false);
        break;
      case 'rating':
        query = query.order('average_rating', ascending: false);
        break;
      case 'price_low':
        query = query.order('price', ascending: true);
        break;
      case 'price_high':
        query = query.order('price', ascending: false);
        break;
      default:
        query = query.order('created_at', ascending: false);
    }

    final offset = (page - 1) * limit;
    final response = await query.range(offset, offset + limit - 1);

    return (response as List).map((c) {
      final course = Map<String, dynamic>.from(c as Map);
      if (course['provider'] != null) {
        course['provider_name'] = course['provider']['name'];
        course['provider_avatar'] = course['provider']['avatar'];
      }
      return CourseModel.fromJson(course);
    }).toList();
  }

  static Future<CourseModel> getCourseById(String courseId) async {
    final response = await _client
        .from('courses')
        .select('*, provider:profiles!courses_provider_id_fkey(name, avatar)')
        .eq('id', courseId)
        .single();

    final course = Map<String, dynamic>.from(response as Map);
    if (course['provider'] != null) {
      course['provider_name'] = course['provider']['name'];
      course['provider_avatar'] = course['provider']['avatar'];
    }

    final ratings = await _client
        .from('ratings')
        .select('rating')
        .eq('course_id', courseId);

    final ratingList =
        (ratings as List).map((r) => (r['rating'] as num).toDouble()).toList();
    if (ratingList.isNotEmpty) {
      course['average_rating'] =
          ratingList.reduce((a, b) => a + b) / ratingList.length;
      course['rating_count'] = ratingList.length;
    }

    return CourseModel.fromJson(course);
  }

  static Future<List<CourseModel>> getEnrolledCourses() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('لم يتم تسجيل الدخول');

    final response = await _client
        .from('enrollments')
        .select('course_id, progress, courses(*)')
        .eq('student_id', userId)
        .order('last_accessed_at', ascending: false);

    return (response as List).map((e) {
      final enrollment = Map<String, dynamic>.from(e as Map);
      final courseData =
          Map<String, dynamic>.from(enrollment['courses'] as Map);
      return CourseModel.fromJson(courseData);
    }).toList();
  }

  // ==================== MODULES ====================

  static Future<List<ModuleModel>> getModulesByCourse(String courseId) async {
    final response = await _client
        .from('modules')
        .select('*, lessons(*)')
        .eq('course_id', courseId)
        .order('order', ascending: true);

    final userId = _client.auth.currentUser?.id;
    List<Map<String, dynamic>> progressData = [];

    if (userId != null) {
      final progressResponse = await _client
          .from('lesson_progress')
          .select('lesson_id, completed, watch_progress')
          .eq('student_id', userId);
      progressData = (progressResponse as List).cast<Map<String, dynamic>>();
    }

    return (response as List).map((m) {
      final module = Map<String, dynamic>.from(m as Map);
      if (module['lessons'] != null) {
        final lessons = (module['lessons'] as List).map((l) {
          final lesson = Map<String, dynamic>.from(l as Map);
          final progress =
              progressData.where((p) => p['lesson_id'] == lesson['id']);
          if (progress.isNotEmpty) {
            lesson['is_completed'] = progress.first['completed'] ?? false;
            lesson['watch_progress'] = progress.first['watch_progress'] ?? 0;
          }
          return LessonModel.fromJson(lesson);
        }).toList();
        lessons.sort((a, b) => a.order.compareTo(b.order));
        module['lessons'] = lessons;
      }
      return ModuleModel.fromJson(module);
    }).toList();
  }

  // ==================== LESSONS ====================

  static Future<LessonModel> getLessonById(String lessonId) async {
    final response =
        await _client.from('lessons').select().eq('id', lessonId).single();

    return LessonModel.fromJson(response);
  }

  static Future<void> markLessonComplete(String lessonId,
      {double watchProgress = 100}) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('لم يتم تسجيل الدخول');

    await _client.rpc('complete_lesson', params: {
      'p_student_id': userId,
      'p_lesson_id': lessonId,
    });
  }

  static Future<Map<String, dynamic>> getLessonProgress(String lessonId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return {'completed': false, 'watch_progress': 0};

    try {
      final response = await _client
          .from('lesson_progress')
          .select()
          .eq('student_id', userId)
          .eq('lesson_id', lessonId)
          .single();
      return {
        'completed': response['completed'] ?? false,
        'watch_progress': response['watch_progress'] ?? 0,
      };
    } catch (_) {
      return {'completed': false, 'watch_progress': 0};
    }
  }

  // ==================== ENROLLMENTS ====================

  static Future<void> enrollInCourse(String courseId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('لم يتم تسجيل الدخول');

    await _client.rpc('enroll_in_course', params: {
      'p_student_id': userId,
      'p_course_id': courseId,
    });
  }

  static Future<EnrollmentModel?> getEnrollment(String courseId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return null;

    try {
      final response = await _client
          .from('enrollments')
          .select(
              '*, course:courses(title, image, level, provider:profiles(name))')
          .eq('student_id', userId)
          .eq('course_id', courseId)
          .single();

      final enrollment = Map<String, dynamic>.from(response as Map);
      if (enrollment['course'] != null) {
        final course = Map<String, dynamic>.from(enrollment['course'] as Map);
        enrollment['course_title'] = course['title'];
        enrollment['course_image'] = course['image'];
        enrollment['course_level'] = course['level'];
        if (course['provider'] != null) {
          enrollment['provider_name'] = course['provider']['name'];
        }
      }
      return EnrollmentModel.fromJson(enrollment);
    } catch (_) {
      return null;
    }
  }

  static Future<List<EnrollmentModel>> getMyEnrollments() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await _client
        .from('enrollments')
        .select(
            '*, course:courses(title, image, level, provider:profiles(name))')
        .eq('student_id', userId)
        .order('last_accessed_at', ascending: false);

    return (response as List).map((e) {
      final enrollment = Map<String, dynamic>.from(e as Map);
      if (enrollment['course'] != null) {
        final course = Map<String, dynamic>.from(enrollment['course'] as Map);
        enrollment['course_title'] = course['title'];
        enrollment['course_image'] = course['image'];
        enrollment['course_level'] = course['level'];
        if (course['provider'] != null) {
          enrollment['provider_name'] = course['provider']['name'];
        }
      }
      return EnrollmentModel.fromJson(enrollment);
    }).toList();
  }

  static Future<double> getCourseProgress(String courseId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return 0;

    try {
      final response = await _client
          .from('enrollments')
          .select('progress')
          .eq('student_id', userId)
          .eq('course_id', courseId)
          .single();
      return (response['progress'] is int)
          ? (response['progress'] as int).toDouble()
          : (response['progress'] ?? 0).toDouble();
    } catch (_) {
      return 0;
    }
  }

  // ==================== EXAMS ====================

  static Future<List<ExamModel>> getExamsByCourse(String courseId) async {
    final response = await _client
        .from('exams')
        .select('*, questions(*, answers(*))')
        .eq('course_id', courseId);

    return (response as List).map((e) {
      final exam = Map<String, dynamic>.from(e as Map);
      if (exam['questions'] != null) {
        final questions = (exam['questions'] as List).map((q) {
          final question = Map<String, dynamic>.from(q as Map);
          if (question['answers'] != null) {
            final answers = (question['answers'] as List)
                .map((a) =>
                    AnswerModel.fromJson(Map<String, dynamic>.from(a as Map)))
                .toList();
            answers.sort((a, b) => a.id.compareTo(b.id));
            question['answers'] = answers;
          }
          return QuestionModel.fromJson(question);
        }).toList();
        questions.sort((a, b) => a.order.compareTo(b.order));
        exam['questions'] = questions;
      }
      return ExamModel.fromJson(exam);
    }).toList();
  }

  static Future<ExamModel> getExamById(String examId) async {
    final response = await _client
        .from('exams')
        .select('*, questions(*, answers(*))')
        .eq('id', examId)
        .single();

    final exam = Map<String, dynamic>.from(response as Map);

    if (exam['questions'] != null) {
      final questions = (exam['questions'] as List).map((q) {
        final question = Map<String, dynamic>.from(q as Map);
        if (question['answers'] != null) {
          final answers = (question['answers'] as List)
              .map((a) =>
                  AnswerModel.fromJson(Map<String, dynamic>.from(a as Map)))
              .toList();
          answers.sort((a, b) => a.id.compareTo(b.id));
          question['answers'] = answers;
        }
        return QuestionModel.fromJson(question);
      }).toList();
      questions.sort((a, b) => a.order.compareTo(b.order));
      exam['questions'] = questions;
    }

    final userId = _client.auth.currentUser?.id;
    if (userId != null) {
      try {
        final attempts = await _client
            .from('exam_attempts')
            .select('id')
            .eq('student_id', userId)
            .eq('exam_id', examId);
        exam['attempts_used'] = (attempts as List).length;
      } catch (_) {}
    }

    return ExamModel.fromJson(exam);
  }

  static Future<String> submitExamAttempt({
    required String examId,
    required Map<String, dynamic> studentAnswers,
    required int timeSpent,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('لم يتم تسجيل الدخول');

    final response = await _client.rpc('submit_exam_attempt', params: {
      'p_student_id': userId,
      'p_exam_id': examId,
      'p_answers': studentAnswers,
      'p_time_spent': timeSpent,
    });

    return response.toString();
  }

  static Future<Map<String, dynamic>> getExamAttempt(String attemptId) async {
    final response = await _client
        .from('exam_attempts')
        .select('*, exam:exams(title, passing_score, duration, course_id)')
        .eq('id', attemptId)
        .single();

    return Map<String, dynamic>.from(response as Map);
  }

  static Future<int> getExamAttemptsCount(String examId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return 0;

    final response = await _client
        .from('exam_attempts')
        .select('id')
        .eq('student_id', userId)
        .eq('exam_id', examId);

    return (response as List).length;
  }

  // ==================== CERTIFICATES ====================

  static Future<List<CertificateModel>> getMyCertificates() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await _client
        .from('certificates')
        .select('*, course:courses(title, image)')
        .eq('student_id', userId)
        .order('issued_at', ascending: false);

    return (response as List).map((c) {
      final cert = Map<String, dynamic>.from(c as Map);
      if (cert['course'] != null) {
        final course = Map<String, dynamic>.from(cert['course'] as Map);
        cert['course_image'] = course['image'];
      }
      return CertificateModel.fromJson(cert);
    }).toList();
  }

  static Future<CertificateModel> getCertificateById(String certId) async {
    final response = await _client
        .from('certificates')
        .select('*, course:courses(title, image), provider:profiles(name)')
        .eq('id', certId)
        .single();

    final cert = Map<String, dynamic>.from(response as Map);
    if (cert['course'] != null) {
      final course = Map<String, dynamic>.from(cert['course'] as Map);
      cert['course_image'] = course['image'];
    }
    if (cert['provider'] != null) {
      cert['provider_name'] = (cert['provider'] as Map)['name'];
    }

    return CertificateModel.fromJson(cert);
  }

  // ==================== NOTIFICATIONS ====================

  static Future<List<NotificationModel>> getMyNotifications() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await _client
        .from('notifications')
        .select()
        .or('user_id.eq.$userId,sent_to_all.eq.true')
        .order('created_at', ascending: false)
        .limit(50);

    return (response as List).map((n) {
      final notif = Map<String, dynamic>.from(n as Map);
      return NotificationModel.fromJson(notif);
    }).toList();
  }

  static Future<void> markNotificationRead(String notificationId) async {
    await _client
        .from('notifications')
        .update({'is_read': true}).eq('id', notificationId);
  }

  static Future<void> markAllNotificationsRead() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    await _client
        .from('notifications')
        .update({'is_read': true}).eq('user_id', userId);
  }

  static Future<int> getUnreadCount() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return 0;

    final response = await _client
        .from('notifications')
        .select('id')
        .eq('user_id', userId)
        .eq('is_read', false);

    return (response as List).length;
  }

  // ==================== RATINGS ====================

  static Future<List<RatingModel>> getCourseRatings(String courseId) async {
    final response = await _client
        .from('ratings')
        .select('*, student:profiles!ratings_student_id_fkey(name, avatar)')
        .eq('course_id', courseId)
        .order('created_at', ascending: false);

    return (response as List).map((r) {
      final rating = Map<String, dynamic>.from(r as Map);
      if (rating['student'] != null) {
        rating['student_name'] = rating['student']['name'];
        rating['student_avatar'] = rating['student']['avatar'];
      }
      return RatingModel.fromJson(rating);
    }).toList();
  }

  static Future<RatingModel?> getMyRating(String courseId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return null;

    try {
      final response = await _client
          .from('ratings')
          .select()
          .eq('student_id', userId)
          .eq('course_id', courseId)
          .single();
      return RatingModel.fromJson(response);
    } catch (_) {
      return null;
    }
  }

  static Future<void> submitRating({
    required String courseId,
    required double rating,
    String? review,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('لم يتم تسجيل الدخول');

    final existing = await getMyRating(courseId);

    if (existing != null) {
      await _client.from('ratings').update({
        'rating': rating,
        'review': review,
      }).eq('id', existing.id);
    } else {
      await _client.from('ratings').insert({
        'rating': rating,
        'review': review,
        'student_id': userId,
        'course_id': courseId,
      });
    }
  }

  // ==================== PROFILE ====================

  static Future<void> updateProfile({
    required String name,
    required String email,
    String? phone,
    String? bio,
    String? gender,
    String? avatar,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('لم يتم تسجيل الدخول');

    final updates = <String, dynamic>{
      'name': name,
      'email': email,
      'phone': phone,
      'bio': bio,
      'gender': gender,
    };

    if (avatar != null) {
      updates['avatar'] = avatar;
    }

    await _client.from('profiles').update(updates).eq('id', userId);

    if (email != _client.auth.currentUser!.email) {
      await _client.auth.updateUser(UserAttributes(email: email));
    }
  }

  static Future<String> uploadAvatar(String filePath) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('لم يتم تسجيل الدخول');

    final fileExt = filePath.split('.').last;
    final fileName = '${userId}_avatar.$fileExt';

    final file = File(filePath);
    final bytes = await file.readAsBytes();

    await _client.storage.from('avatars').uploadBinary(fileName, bytes,
        fileOptions: const FileOptions(upsert: true));

    final url = _client.storage.from('avatars').getPublicUrl(fileName);
    return url;
  }

  // ==================== STORAGE ====================

  static String getPublicUrl(String bucket, String path) {
    return _client.storage.from(bucket).getPublicUrl(path);
  }

  // ==================== STATS ====================

  static Future<Map<String, dynamic>> getStudentStats() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return {};

    final enrollments = await _client
        .from('enrollments')
        .select('id, progress, completed_at')
        .eq('student_id', userId);

    final certificates = await _client
        .from('certificates')
        .select('id')
        .eq('student_id', userId);

    return {
      'total_enrollments': (enrollments as List).length,
      'completed_courses':
          (enrollments as List).where((e) => e['completed_at'] != null).length,
      'in_progress':
          (enrollments as List).where((e) => e['completed_at'] == null).length,
      'total_certificates': (certificates as List).length,
    };
  }

  // ==================== CATEGORIES ====================

  static Future<List<String>> getCategories() async {
    final response = await _client
        .from('courses')
        .select('category')
        .eq('status', 'PUBLISHED')
        .not('category', 'is', null);

    final categories =
        (response as List).map((c) => c['category'] as String).toSet().toList();
    categories.sort();
    return categories;
  }
}
