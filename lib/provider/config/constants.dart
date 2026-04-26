class AppConstants {
  // App info
  static const String appName = 'وصلة - مزود الخدمة';
  static const String appVersion = '1.0.0';

  // Roles
  static const String roleProvider = 'provider';
  static const String roleStudent = 'student';
  static const String roleAdmin = 'admin';

  // Course levels (DB enum values)
  static const String levelBeginner = 'BEGINNER';
  static const String levelIntermediate = 'INTERMEDIATE';
  static const String levelAdvanced = 'ADVANCED';

  // Course level display names
  static const String levelBeginnerText = 'مبتدئ';
  static const String levelIntermediateText = 'متوسط';
  static const String levelAdvancedText = 'متقدم';

  // Course statuses (DB enum values)
  static const String statusDraft = 'DRAFT';
  static const String statusPublished = 'PUBLISHED';
  static const String statusArchived = 'ARCHIVED';

  // Lesson types (DB enum values)
  static const String lessonTypeVideo = 'VIDEO';
  static const String lessonTypePdf = 'PDF';
  static const String lessonTypeText = 'TEXT';
  static const String lessonTypeDocument = 'FILE';
  static const String lessonTypeAudio = 'AUDIO';
  static const String lessonTypeImage = 'IMAGE';

  // Lesson type display names
  static const String lessonTypeVideoText = 'فيديو';
  static const String lessonTypePdfText = 'PDF';
  static const String lessonTypeTextText = 'نص';
  static const String lessonTypeDocumentText = 'مستند';
  static const String lessonTypeAudioText = 'صوتي';
  static const String lessonTypeImageText = 'صورة';

  // Question types (DB enum values)
  static const String questionTypeMultipleChoice = 'MULTIPLE_CHOICE';
  static const String questionTypeTrueFalse = 'TRUE_FALSE';
  static const String questionTypeText = 'TEXT';

  // Question type display names
  static const String questionTypeMultipleChoiceText = 'اختيار متعدد';
  static const String questionTypeTrueFalseText = 'صح/خطأ';
  static const String questionTypeTextText = 'نصي';

  // Notification types
  static const String notifTypeSystem = 'نظام';
  static const String notifTypeEnrollment = 'تسجيل';
  static const String notifTypeCertificate = 'شهادة';
  static const String notifTypePayment = 'دفعة';

  // Payment statuses (DB enum values)
  static const String paymentStatusPending = 'PENDING';
  static const String paymentStatusApproved = 'APPROVED';
  static const String paymentStatusRejected = 'REJECTED';
  static const String paymentStatusRefunded = 'REFUNDED';

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

  // Course levels list (DB enum values)
  static const List<String> levels = [
    levelBeginner,
    levelIntermediate,
    levelAdvanced,
  ];

  // Course levels display names
  static const List<String> levelsText = [
    levelBeginnerText,
    levelIntermediateText,
    levelAdvancedText,
  ];

  // Pagination
  static const int defaultPageSize = 20;

  // File size limits (in bytes)
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const int maxVideoSize = 500 * 1024 * 1024; // 500MB
  static const int maxFileSize = 100 * 1024 * 1024; // 100MB
  static const int maxAudioSize = 50 * 1024 * 1024; // 50MB
}
