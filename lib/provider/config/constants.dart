class AppConstants {
  // App info
  static const String appName = 'وصلة - مزود الخدمة';
  static const String appVersion = '1.0.0';

  // Roles
  static const String roleProvider = 'provider';
  static const String roleStudent = 'student';
  static const String roleAdmin = 'admin';

  // Course levels
  static const String levelBeginner = 'مبتدئ';
  static const String levelIntermediate = 'متوسط';
  static const String levelAdvanced = 'متقدم';

  // Course statuses
  static const String statusDraft = 'مسودة';
  static const String statusPublished = 'منشور';

  // Lesson types
  static const String lessonTypeVideo = 'فيديو';
  static const String lessonTypePdf = 'PDF';
  static const String lessonTypeDocument = 'مستند';
  static const String lessonTypeAudio = 'صوتي';
  static const String lessonTypeImage = 'صورة';

  // Question types
  static const String questionTypeMultipleChoice = 'اختيار متعدد';
  static const String questionTypeTrueFalse = 'صح/خطأ';
  static const String questionTypeText = 'نصي';

  // Notification types
  static const String notifTypeSystem = 'نظام';
  static const String notifTypeEnrollment = 'تسجيل';
  static const String notifTypeCertificate = 'شهادة';
  static const String notifTypePayment = 'دفعة';

  // Payment statuses
  static const String paymentStatusPending = 'معلق';
  static const String paymentStatusApproved = 'معتمد';
  static const String paymentStatusRejected = 'مرفوض';

  // Payment methods
  static const String paymentMethodBank = 'تحويل بنكي';
  static const String paymentMethodWallet = 'محفظة إلكترونية';
  static const String paymentMethodCash = 'نقدي';

  // Subscription plans
  static const String planFree = 'مجاني';
  static const String planBasic = 'أساسي';
  static const String planPremium = 'مميز';

  // Storage buckets
  static const String bucketCourseImages = 'course-images';
  static const String bucketCourseVideos = 'course-videos';
  static const String bucketCourseFiles = 'course-files';
  static const String bucketCourseAudio = 'course-audio';
  static const String bucketCertificates = 'certificates';
  static const String bucketPaymentProofs = 'payment-proofs';
  static const String bucketAvatars = 'avatars';

  // Categories
  static const List<String> categories = [
    'برمجة',
    'تصميم',
    'تسويق',
    'إدارة أعمال',
    'لغات',
    'علوم',
    'رياضيات',
    'هندسة',
    'طب',
    'قانون',
    'أخرى',
  ];

  // Course levels list
  static const List<String> levels = [
    levelBeginner,
    levelIntermediate,
    levelAdvanced,
  ];

  // Pagination
  static const int defaultPageSize = 20;

  // File size limits (in bytes)
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const int maxVideoSize = 500 * 1024 * 1024; // 500MB
  static const int maxFileSize = 100 * 1024 * 1024; // 100MB
  static const int maxAudioSize = 50 * 1024 * 1024; // 50MB
}
