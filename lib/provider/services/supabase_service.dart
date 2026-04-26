import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;
import '../models/course_model.dart';
import '../models/module_model.dart';
import '../models/lesson_model.dart';
import '../models/exam_model.dart';
import '../models/question_model.dart';
import '../models/answer_model.dart';
import '../models/certificate_model.dart';
import '../models/notification_model.dart';
import '../models/payment_model.dart';
import '../models/user_model.dart';
import 'storage_service.dart';

class SupabaseService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final StorageService _storageService = StorageService();

  // ==================== Courses ====================

  Future<List<CourseModel>> getCourses({String? providerId}) async {
    try {
      final userId = providerId ?? _supabase.auth.currentUser!.id;
      var query = _supabase
          .from('courses')
          .select('*, modules(count), enrollments(count)')
          .eq('provider_id', userId)
          .order('created_at', ascending: false);

      final response = await query;
      return response.map<CourseModel>((json) {
        final course = CourseModel.fromJson(json);
        final modules = json['modules'] as List?;
        final enrollments = json['enrollments'] as List?;
        return course.copyWith(
          modulesCount: modules?.length ?? 0,
          studentsCount: enrollments?.length ?? 0,
        );
      }).toList();
    } catch (e) {
      throw Exception('فشل في جلب الدورات');
    }
  }

  Future<CourseModel> getCourseById(String courseId) async {
    try {
      final response = await _supabase
          .from('courses')
          .select('*, modules(count), enrollments(count)')
          .eq('id', courseId)
          .single();

      final course = CourseModel.fromJson(response);
      final modules = response['modules'] as List?;
      final enrollments = response['enrollments'] as List?;
      return course.copyWith(
        modulesCount: modules?.length ?? 0,
        studentsCount: enrollments?.length ?? 0,
      );
    } catch (e) {
      throw Exception('فشل في جلب بيانات الدورة');
    }
  }

  Future<CourseModel> createCourse({
    required String title,
    required String description,
    required double price,
    required String level,
    required String category,
    File? imageFile,
  }) async {
    try {
      String? imageUrl;
      if (imageFile != null) {
        imageUrl = await _storageService.uploadImage(
          file: imageFile,
          folder: 'courses',
        );
      }

      final userId = _supabase.auth.currentUser!.id;
      final response = await _supabase
          .from('courses')
          .insert({
            'title': title,
            'description': description,
            'price': price,
            'level': level,
            'category': category,
            'image': imageUrl,
            'status': 'DRAFT',
            'provider_id': userId,
          })
          .select()
          .single();

      return CourseModel.fromJson(response);
    } catch (e) {
      throw Exception('فشل في إنشاء الدورة');
    }
  }

  Future<CourseModel> updateCourse({
    required String courseId,
    String? title,
    String? description,
    double? price,
    String? level,
    String? category,
    File? imageFile,
  }) async {
    try {
      Map<String, dynamic> updates = {};
      if (title != null) updates['title'] = title;
      if (description != null) updates['description'] = description;
      if (price != null) updates['price'] = price;
      if (level != null) updates['level'] = level;
      if (category != null) updates['category'] = category;

      if (imageFile != null) {
        updates['image'] = await _storageService.uploadImage(
          file: imageFile,
          folder: 'courses',
        );
      }

      updates['updated_at'] = DateTime.now().toIso8601String();

      final response = await _supabase
          .from('courses')
          .update(updates)
          .eq('id', courseId)
          .select()
          .single();

      return CourseModel.fromJson(response);
    } catch (e) {
      throw Exception('فشل في تحديث الدورة');
    }
  }

  Future<void> deleteCourse(String courseId) async {
    try {
      await _supabase.from('courses').delete().eq('id', courseId);
    } catch (e) {
      throw Exception('فشل في حذف الدورة');
    }
  }

  Future<void> publishCourse(String courseId, bool publish) async {
    try {
      await _supabase.from('courses').update({
        'status': publish ? 'PUBLISHED' : 'DRAFT',
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', courseId);
    } catch (e) {
      throw Exception('فشل في تحديث حالة الدورة');
    }
  }

  // ==================== Modules ====================

  Future<List<ModuleModel>> getModulesByCourse(String courseId) async {
    try {
      final response = await _supabase
          .from('modules')
          .select('*, lessons(count)')
          .eq('course_id', courseId)
          .order('order', ascending: true);

      return response.map<ModuleModel>((json) {
        final module = ModuleModel.fromJson(json);
        final lessons = json['lessons'] as List?;
        return module.copyWith(lessonsCount: lessons?.length ?? 0);
      }).toList();
    } catch (e) {
      throw Exception('فشل في جلب الوحدات');
    }
  }

  Future<ModuleModel> createModule({
    required String title,
    required String courseId,
    required int order,
  }) async {
    try {
      final response = await _supabase
          .from('modules')
          .insert({
            'title': title,
            'course_id': courseId,
            'order': order,
          })
          .select()
          .single();

      return ModuleModel.fromJson(response);
    } catch (e) {
      throw Exception('فشل في إنشاء الوحدة');
    }
  }

  Future<ModuleModel> updateModule({
    required String moduleId,
    String? title,
    int? order,
  }) async {
    try {
      Map<String, dynamic> updates = {};
      if (title != null) updates['title'] = title;
      if (order != null) updates['order'] = order;

      final response = await _supabase
          .from('modules')
          .update(updates)
          .eq('id', moduleId)
          .select()
          .single();

      return ModuleModel.fromJson(response);
    } catch (e) {
      throw Exception('فشل في تحديث الوحدة');
    }
  }

  Future<void> deleteModule(String moduleId) async {
    try {
      await _supabase.from('modules').delete().eq('id', moduleId);
    } catch (e) {
      throw Exception('فشل في حذف الوحدة');
    }
  }

  Future<void> reorderModules(List<Map<String, dynamic>> moduleOrders) async {
    try {
      for (final item in moduleOrders) {
        await _supabase
            .from('modules')
            .update({'order': item['order']}).eq('id', item['id']);
      }
    } catch (e) {
      throw Exception('فشل في إعادة ترتيب الوحدات');
    }
  }

  // ==================== Lessons ====================

  Future<List<LessonModel>> getLessonsByModule(String moduleId) async {
    try {
      final response = await _supabase
          .from('lessons')
          .select()
          .eq('module_id', moduleId)
          .order('order', ascending: true);

      return response
          .map<LessonModel>((json) => LessonModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('فشل في جلب الدروس');
    }
  }

  Future<LessonModel> createLesson({
    required String title,
    required String type,
    required String moduleId,
    required int order,
    String? content,
    File? file,
    String? fileName,
    int? fileSize,
    int? duration,
  }) async {
    try {
      String? fileUrl;
      if (file != null) {
        final bucket = _storageService.getBucketForFileType(type);
        fileUrl = await _storageService.uploadFile(
          file: file,
          bucket: bucket,
          path: '$moduleId/${file.uri.pathSegments.last}',
        );
      }

      final response = await _supabase
          .from('lessons')
          .insert({
            'title': title,
            'type': type,
            'module_id': moduleId,
            'order': order,
            'content': content,
            'file_url': fileUrl,
            'file_name': fileName,
            'file_size': fileSize,
            'duration': duration,
          })
          .select()
          .single();

      return LessonModel.fromJson(response);
    } catch (e) {
      throw Exception('فشل في إنشاء الدرس');
    }
  }

  Future<LessonModel> updateLesson({
    required String lessonId,
    String? title,
    String? type,
    String? content,
    File? file,
    String? fileName,
    int? fileSize,
    int? duration,
    int? order,
  }) async {
    try {
      Map<String, dynamic> updates = {};
      if (title != null) updates['title'] = title;
      if (type != null) updates['type'] = type;
      if (content != null) updates['content'] = content;
      if (fileName != null) updates['file_name'] = fileName;
      if (fileSize != null) updates['file_size'] = fileSize;
      if (duration != null) updates['duration'] = duration;
      if (order != null) updates['order'] = order;

      if (file != null) {
        final bucket = _storageService.getBucketForFileType(type ?? 'فيديو');
        updates['file_url'] = await _storageService.uploadFile(
          file: file,
          bucket: bucket,
          path: 'lessons/$lessonId/${file.uri.pathSegments.last}',
        );
      }

      final response = await _supabase
          .from('lessons')
          .update(updates)
          .eq('id', lessonId)
          .select()
          .single();

      return LessonModel.fromJson(response);
    } catch (e) {
      throw Exception('فشل في تحديث الدرس');
    }
  }

  Future<void> deleteLesson(String lessonId) async {
    try {
      await _supabase.from('lessons').delete().eq('id', lessonId);
    } catch (e) {
      throw Exception('فشل في حذف الدرس');
    }
  }

  Future<void> reorderLessons(List<Map<String, dynamic>> lessonOrders) async {
    try {
      for (final item in lessonOrders) {
        await _supabase
            .from('lessons')
            .update({'order': item['order']}).eq('id', item['id']);
      }
    } catch (e) {
      throw Exception('فشل في إعادة ترتيب الدروس');
    }
  }

  // ==================== Exams ====================

  Future<List<ExamModel>> getExamsByCourse(String courseId) async {
    try {
      final response = await _supabase
          .from('exams')
          .select('*, questions(count)')
          .eq('course_id', courseId)
          .order('created_at', ascending: false);

      return response.map<ExamModel>((json) {
        final exam = ExamModel.fromJson(json);
        final questions = json['questions'] as List?;
        return exam.copyWith(questionsCount: questions?.length ?? 0);
      }).toList();
    } catch (e) {
      throw Exception('فشل في جلب الامتحانات');
    }
  }

  Future<ExamModel> createExam({
    required String title,
    required String description,
    required int passingScore,
    required String courseId,
    int duration = 30,
    int maxAttempts = 3,
  }) async {
    try {
      final response = await _supabase
          .from('exams')
          .insert({
            'title': title,
            'description': description,
            'passing_score': passingScore,
            'course_id': courseId,
            'duration': duration,
            'max_attempts': maxAttempts,
          })
          .select()
          .single();

      return ExamModel.fromJson(response);
    } catch (e) {
      throw Exception('فشل في إنشاء الامتحان');
    }
  }

  Future<ExamModel> updateExam({
    required String examId,
    String? title,
    String? description,
    int? passingScore,
    int? duration,
    int? maxAttempts,
  }) async {
    try {
      Map<String, dynamic> updates = {};
      if (title != null) updates['title'] = title;
      if (description != null) updates['description'] = description;
      if (passingScore != null) updates['passing_score'] = passingScore;
      if (duration != null) updates['duration'] = duration;
      if (maxAttempts != null) updates['max_attempts'] = maxAttempts;

      final response = await _supabase
          .from('exams')
          .update(updates)
          .eq('id', examId)
          .select()
          .single();

      return ExamModel.fromJson(response);
    } catch (e) {
      throw Exception('فشل في تحديث الامتحان');
    }
  }

  Future<void> deleteExam(String examId) async {
    try {
      await _supabase.from('exams').delete().eq('id', examId);
    } catch (e) {
      throw Exception('فشل في حذف الامتحان');
    }
  }

  // ==================== Questions ====================

  Future<List<QuestionModel>> getQuestionsByExam(String examId) async {
    try {
      final response = await _supabase
          .from('questions')
          .select('*, answers(*)')
          .eq('exam_id', examId)
          .order('order', ascending: true);

      return response
          .map<QuestionModel>((json) => QuestionModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('فشل في جلب الأسئلة');
    }
  }

  Future<QuestionModel> createQuestion({
    required String text,
    required String type,
    required int points,
    required String examId,
    required int order,
    List<Map<String, dynamic>>? answers,
  }) async {
    try {
      final response = await _supabase
          .from('questions')
          .insert({
            'text': text,
            'type': type,
            'points': points,
            'exam_id': examId,
            'order': order,
          })
          .select()
          .single();

      final question = QuestionModel.fromJson(response);

      if (answers != null && answers.isNotEmpty) {
        for (final answer in answers) {
          await _supabase.from('answers').insert({
            'text': answer['text'],
            'is_correct': answer['is_correct'] ?? false,
            'question_id': question.id,
          });
        }
      }

      return question;
    } catch (e) {
      throw Exception('فشل في إنشاء السؤال');
    }
  }

  Future<QuestionModel> updateQuestion({
    required String questionId,
    String? text,
    String? type,
    int? points,
    int? order,
  }) async {
    try {
      Map<String, dynamic> updates = {};
      if (text != null) updates['text'] = text;
      if (type != null) updates['type'] = type;
      if (points != null) updates['points'] = points;
      if (order != null) updates['order'] = order;

      final response = await _supabase
          .from('questions')
          .update(updates)
          .eq('id', questionId)
          .select()
          .single();

      return QuestionModel.fromJson(response);
    } catch (e) {
      throw Exception('فشل في تحديث السؤال');
    }
  }

  Future<void> deleteQuestion(String questionId) async {
    try {
      await _supabase.from('answers').delete().eq('question_id', questionId);
      await _supabase.from('questions').delete().eq('id', questionId);
    } catch (e) {
      throw Exception('فشل في حذف السؤال');
    }
  }

  // ==================== Answers ====================

  Future<List<AnswerModel>> getAnswersByQuestion(String questionId) async {
    try {
      final response = await _supabase
          .from('answers')
          .select()
          .eq('question_id', questionId)
          .order('created_at', ascending: true);

      return response
          .map<AnswerModel>((json) => AnswerModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('فشل في جلب الإجابات');
    }
  }

  Future<AnswerModel> createAnswer({
    required String text,
    required bool isCorrect,
    required String questionId,
  }) async {
    try {
      final response = await _supabase
          .from('answers')
          .insert({
            'text': text,
            'is_correct': isCorrect,
            'question_id': questionId,
          })
          .select()
          .single();

      return AnswerModel.fromJson(response);
    } catch (e) {
      throw Exception('فشل في إنشاء الإجابة');
    }
  }

  Future<void> updateAnswer({
    required String answerId,
    String? text,
    bool? isCorrect,
  }) async {
    try {
      Map<String, dynamic> updates = {};
      if (text != null) updates['text'] = text;
      if (isCorrect != null) updates['is_correct'] = isCorrect;

      await _supabase.from('answers').update(updates).eq('id', answerId);
    } catch (e) {
      throw Exception('فشل في تحديث الإجابة');
    }
  }

  Future<void> deleteAnswer(String answerId) async {
    try {
      await _supabase.from('answers').delete().eq('id', answerId);
    } catch (e) {
      throw Exception('فشل في حذف الإجابة');
    }
  }

  // ==================== Students ====================

  Future<List<UserModel>> getStudentsByCourse(String courseId) async {
    try {
      final response = await _supabase
          .from('enrollments')
          .select(
              'student_id, progress, profiles!enrollments_student_id_fkey(*)')
          .eq('course_id', courseId);

      return response.map<UserModel>((json) {
        final profile = json['profiles'] as Map<String, dynamic>;
        return UserModel.fromJson(profile);
      }).toList();
    } catch (e) {
      throw Exception('فشل في جلب قائمة الطلاب');
    }
  }

  // ==================== Certificates ====================

  Future<List<CertificateModel>> getCertificatesByProvider(
      String providerId) async {
    try {
      final response = await _supabase
          .from('certificates')
          .select()
          .eq('provider_id', providerId)
          .order('created_at', ascending: false);

      return response
          .map<CertificateModel>((json) => CertificateModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('فشل في جلب الشهادات');
    }
  }

  Future<List<CertificateModel>> getCertificatesByCourse(
      String courseId) async {
    try {
      final response = await _supabase
          .from('certificates')
          .select()
          .eq('course_id', courseId)
          .order('created_at', ascending: false);

      return response
          .map<CertificateModel>((json) => CertificateModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('فشل في جلب الشهادات');
    }
  }

  Future<CertificateModel> issueCertificate({
    required String studentName,
    required String courseName,
    required String providerName,
    required double score,
    required String studentId,
    required String courseId,
    required String providerId,
  }) async {
    try {
      final certNumber = 'CERT-${DateTime.now().millisecondsSinceEpoch}';

      final response = await _supabase
          .from('certificates')
          .insert({
            'certificate_number': certNumber,
            'student_name': studentName,
            'course_name': courseName,
            'provider_name': providerName,
            'score': score,
            'student_id': studentId,
            'course_id': courseId,
            'provider_id': providerId,
          })
          .select()
          .single();

      return CertificateModel.fromJson(response);
    } catch (e) {
      throw Exception('فشل في إصدار الشهادة');
    }
  }

  // ==================== Certificate Templates ====================

  Future<List<Map<String, dynamic>>> getCertificateTemplates(
      String providerId) async {
    try {
      final response = await _supabase
          .from('certificate_templates')
          .select()
          .eq('provider_id', providerId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('فشل في جلب قوالب الشهادات');
    }
  }

  Future<void> createCertificateTemplate({
    required String name,
    required String backgroundColor,
    required String textColor,
    String? logoUrl,
    String? signatureUrl,
  }) async {
    try {
      final userId = _supabase.auth.currentUser!.id;
      await _supabase.from('certificate_templates').insert({
        'name': name,
        'background_color': backgroundColor,
        'text_color': textColor,
        'logo_url': logoUrl,
        'signature_url': signatureUrl,
        'provider_id': userId,
      });
    } catch (e) {
      throw Exception('فشل في إنشاء قالب الشهادة');
    }
  }

  Future<void> updateCertificateTemplate({
    required String templateId,
    String? name,
    String? backgroundColor,
    String? textColor,
    String? logoUrl,
    String? signatureUrl,
  }) async {
    try {
      Map<String, dynamic> updates = {};
      if (name != null) updates['name'] = name;
      if (backgroundColor != null) {
        updates['background_color'] = backgroundColor;
      }
      if (textColor != null) updates['text_color'] = textColor;
      if (logoUrl != null) updates['logo_url'] = logoUrl;
      if (signatureUrl != null) updates['signature_url'] = signatureUrl;

      await _supabase
          .from('certificate_templates')
          .update(updates)
          .eq('id', templateId);
    } catch (e) {
      throw Exception('فشل في تحديث قالب الشهادة');
    }
  }

  Future<void> deleteCertificateTemplate(String templateId) async {
    try {
      await _supabase
          .from('certificate_templates')
          .delete()
          .eq('id', templateId);
    } catch (e) {
      throw Exception('فشل في حذف قالب الشهادة');
    }
  }

  // ==================== Notifications ====================

  Future<List<NotificationModel>> getMyNotifications() async {
    try {
      final userId = _supabase.auth.currentUser!.id;
      final response = await _supabase
          .from('notifications')
          .select()
          .or('user_id.eq.$userId,sent_to_all.eq.true')
          .order('created_at', ascending: false);

      return response
          .map<NotificationModel>((json) => NotificationModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('فشل في جلب الإشعارات');
    }
  }

  Future<void> createNotification({
    required String title,
    required String message,
    required String type,
    String? userId,
    bool sentToAll = false,
  }) async {
    try {
      await _supabase.from('notifications').insert({
        'title': title,
        'message': message,
        'type': type,
        'user_id': userId,
        'sent_to_all': sentToAll,
      });
    } catch (e) {
      throw Exception('فشل في إنشاء الإشعار');
    }
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _supabase
          .from('notifications')
          .update({'is_read': true}).eq('id', notificationId);
    } catch (e) {
      throw Exception('فشل في تحديث الإشعار');
    }
  }

  // ==================== Payments ====================

  Future<List<PaymentModel>> getPaymentsByProvider() async {
    try {
      final userId = _supabase.auth.currentUser!.id;
      final response = await _supabase
          .from('payments')
          .select()
          .eq('provider_id', userId)
          .order('created_at', ascending: false);

      return response
          .map<PaymentModel>((json) => PaymentModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('فشل في جلب المدفوعات');
    }
  }

  Future<PaymentModel> createPayment({
    required double amount,
    required String paymentMethod,
    String? proofUrl,
  }) async {
    try {
      final userId = _supabase.auth.currentUser!.id;
      final response = await _supabase
          .from('payments')
          .insert({
            'amount': amount,
            'status': 'PENDING',
            'payment_method': paymentMethod,
            'proof_url': proofUrl,
            'provider_id': userId,
          })
          .select()
          .single();

      return PaymentModel.fromJson(response);
    } catch (e) {
      throw Exception('فشل في إنشاء عملية الدفع');
    }
  }

  Future<PaymentModel> uploadPaymentProof({
    required String paymentId,
    required File proofFile,
  }) async {
    try {
      final url = await _storageService.uploadPaymentProof(
        file: proofFile,
        userId: _supabase.auth.currentUser!.id,
      );

      final response = await _supabase
          .from('payments')
          .update({'proof_url': url})
          .eq('id', paymentId)
          .select()
          .single();

      return PaymentModel.fromJson(response);
    } catch (e) {
      throw Exception('فشل في رفع إثبات الدفع');
    }
  }

  // ==================== Dashboard Stats ====================

  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final userId = _supabase.auth.currentUser!.id;

      final coursesResponse = await _supabase
          .from('courses')
          .select('id')
          .eq('provider_id', userId);

      final enrollmentsResponse = await _supabase
          .from('enrollments')
          .select('course_id')
          .inFilter('course_id',
              coursesResponse.map((c) => c['id'] as String).toList());

      final certificatesResponse = await _supabase
          .from('certificates')
          .select('id')
          .eq('provider_id', userId);

      final paymentsResponse = await _supabase
          .from('payments')
          .select('amount, status')
          .eq('provider_id', userId);

      double totalRevenue = 0;
      for (final p in paymentsResponse) {
        if (p['status'] == 'APPROVED') {
          totalRevenue += (p['amount'] as num).toDouble();
        }
      }

      return {
        'totalCourses': coursesResponse.length,
        'totalStudents': enrollmentsResponse.toSet().length,
        'totalCertificates': certificatesResponse.length,
        'totalRevenue': totalRevenue,
      };
    } catch (e) {
      throw Exception('فشل في جلب إحصائيات لوحة التحكم');
    }
  }

  // ==================== Storage Upload ====================

  Future<String> uploadFile({
    required File file,
    required String bucket,
    required String path,
    void Function(double)? onProgress,
  }) async {
    return _storageService.uploadFile(
      file: file,
      bucket: bucket,
      path: path,
      onProgress: onProgress,
    );
  }
}
