class Constants {
  // App Info
  static const String appName = 'وسلة';
  static const String appNameAr = 'وسلة - منصة تعليمية';

  // Screen Transitions
  static const Duration transitionDuration = Duration(milliseconds: 300);

  // Pagination
  static const int itemsPerPage = 20;

  // Timer
  static const int examWarningSeconds = 60;

  // File size limits (MB)
  static const int maxAvatarSizeMB = 5;

  // Animation durations
  static const Duration shimmerDuration = Duration(milliseconds: 1500);

  // Categories
  static const List<String> categories = [
    'تطوير الويب',
    'تطوير الموبايل',
    'الذكاء الاصطناعي',
    'تصميم الجرافيك',
    'إدارة الأعمال',
    'التسويق الرقمي',
    'علوم البيانات',
    'الأمن السيبراني',
    'الشبكات',
    'قواعد البيانات',
  ];

  // Levels
  static const List<String> levels = [
    'مبتدئ',
    'متوسط',
    'متقدم',
  ];

  // Level colors
  static const Map<String, int> levelColors = {
    'مبتدئ': 0xFF10B981,
    'متوسط': 0xFFF59E0B,
    'متقدم': 0xFFEF4444,
  };

  // Lesson Types
  static const List<String> lessonTypes = [
    'video',
    'pdf',
    'text',
    'file',
    'image',
    'audio',
  ];

  static const Map<String, String> lessonTypeLabels = {
    'video': 'فيديو',
    'pdf': 'ملف PDF',
    'text': 'نص',
    'file': 'ملف',
    'image': 'صورة',
    'audio': 'صوت',
  };

  // Exam question types
  static const List<String> questionTypes = [
    'multiple_choice',
    'true_false',
  ];

  // Notification types
  static const Map<String, String> notificationTypeLabels = {
    'enrollment': 'تسجيل جديد',
    'exam': 'اختبار',
    'certificate': 'شهادة',
    'announcement': 'إعلان',
    'system': 'نظام',
  };

  // Validation messages
  static const String requiredField = 'هذا الحقل مطلوب';
  static const String invalidEmail = 'البريد الإلكتروني غير صحيح';
  static const String passwordTooShort = 'كلمة المرور يجب أن تكون 8 أحرف على الأقل';
  static const String passwordsDoNotMatch = 'كلمة المرور غير متطابقة';
  static const String invalidPhone = 'رقم الهاتف غير صحيح';
  static const String nameTooShort = 'الاسم يجب أن يكون 3 أحرف على الأقل';

  // Success/Error messages
  static const String loginSuccess = 'تم تسجيل الدخول بنجاح';
  static const String registerSuccess = 'تم إنشاء الحساب بنجاح';
  static const String logoutSuccess = 'تم تسجيل الخروج بنجاح';
  static const String enrollSuccess = 'تم التسجيل في الدورة بنجاح';
  static const String ratingSubmitSuccess = 'تم إرسال التقييم بنجاح';
  static const String profileUpdateSuccess = 'تم تحديث الملف الشخصي بنجاح';
  static const String lessonCompleteSuccess = 'تم إكمال الدرس بنجاح';
  static const String examSubmitSuccess = 'تم إرسال الإجابات بنجاح';
  static const String generalError = 'حدث خطأ غير متوقع';
  static const String networkError = 'خطأ في الاتصال بالشبكة';
  static const String noData = 'لا توجد بيانات';
  static const String pullToRefresh = 'اسحب للتحديث';
}
