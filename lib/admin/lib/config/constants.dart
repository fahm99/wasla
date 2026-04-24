class Constants {
  // Statuses
  static const String statusPending = 'PENDING';
  static const String statusActive = 'ACTIVE';
  static const String statusSuspended = 'SUSPENDED';
  static const String statusRejected = 'REJECTED';
  static const String statusPublished = 'PUBLISHED';
  static const String statusArchived = 'ARCHIVED';
  static const String statusDraft = 'DRAFT';
  static const String statusApproved = 'APPROVED';
  static const String statusRejectedPayment = 'REJECTED';

  // Roles
  static const String roleAdmin = 'ADMIN';
  static const String roleProvider = 'PROVIDER';
  static const String roleStudent = 'STUDENT';

  // App Strings
  static const String appName = 'وصلة';
  static const String appSubtitle = 'لوحة تحكم المشرف';

  // Bottom Nav Labels
  static const String navDashboard = 'الرئيسية';
  static const String navAccounts = 'الحسابات';
  static const String navPayments = 'المدفوعات';
  static const String navNotifications = 'الإشعارات';
  static const String navReports = 'التقارير';
  static const String navProfile = 'البروفايل';

  // Screen Titles
  static const String titleLogin = 'تسجيل الدخول';
  static const String titleDashboard = 'لوحة التحكم';
  static const String titleAccounts = 'إدارة الحسابات';
  static const String titleCourses = 'إدارة الكورسات';
  static const String titlePayments = 'المدفوعات والاشتراكات';
  static const String titleNotifications = 'الإشعارات';
  static const String titleSendNotification = 'إرسال إشعار';
  static const String titleReports = 'التقارير';
  static const String titleProfile = 'البروفايل';
  static const String titleSettings = 'الإعدادات';
  static const String titleChangePassword = 'تغيير كلمة المرور';

  // Actions
  static const String actionApprove = 'قبول';
  static const String actionReject = 'رفض';
  static const String actionSuspend = 'تعليق';
  static const String actionActivate = 'تفعيل';
  static const String actionPublish = 'نشر';
  static const String actionArchive = 'أرشفة';
  static const String actionDelete = 'حذف';
  static const String actionEdit = 'تعديل';
  static const String actionSave = 'حفظ';
  static const String actionCancel = 'إلغاء';
  static const String actionConfirm = 'تأكيد';
  static const String actionSend = 'إرسال';
  static const String actionLogout = 'تسجيل الخروج';
  static const String actionRefresh = 'تحديث';

  // Messages
  static const String msgLoginSuccess = 'تم تسجيل الدخول بنجاح';
  static const String msgLoginError = 'فشل تسجيل الدخول';
  static const String msgLogoutSuccess = 'تم تسجيل الخروج بنجاح';
  static const String msgApproveSuccess = 'تم القبول بنجاح';
  static const String msgRejectSuccess = 'تم الرفض بنجاح';
  static const String msgSuspendSuccess = 'تم التعليق بنجاح';
  static const String msgActivateSuccess = 'تم التفعيل بنجاح';
  static const String msgPublishSuccess = 'تم النشر بنجاح';
  static const String msgArchiveSuccess = 'تم الأرشفة بنجاح';
  static const String msgSendSuccess = 'تم الإرسال بنجاح';
  static const String msgUpdateSuccess = 'تم التحديث بنجاح';
  static const String msgDeleteSuccess = 'تم الحذف بنجاح';
  static const String msgError = 'حدث خطأ';
  static const String msgNoData = 'لا توجد بيانات';
  static const String msgNoInternet = 'لا يوجد اتصال بالإنترنت';
  static const String msgAdminOnly = 'هذا الحساب ليس حساب مشرف';
  static const String msgEmptyFields = 'يرجى ملء جميع الحقول';
  static const String msgConfirmAction = 'هل أنت متأكد؟';
  static const String msgCannotUndo = 'لا يمكن التراجع عن هذا الإجراء';

  // Hints
  static const String hintEmail = 'البريد الإلكتروني';
  static const String hintPassword = 'كلمة المرور';
  static const String hintCurrentPassword = 'كلمة المرور الحالية';
  static const String hintNewPassword = 'كلمة المرور الجديدة';
  static const String hintConfirmPassword = 'تأكيد كلمة المرور';
  static const String hintSearch = 'بحث...';
  static const String hintNotificationTitle = 'عنوان الإشعار';
  static const String hintNotificationMessage = 'نص الإشعار';

  // Tab Labels
  static const String tabPending = 'المعلقة';
  static const String tabActive = 'النشطة';
  static const String tabSuspended = 'المعلقة';
  static const String tabAll = 'الكل';
  static const String tabApproved = 'مقبولة';
  static const String tabRejectedPayment = 'مرفوضة';

  // Stats Labels
  static const String statActiveProviders = 'المقدمين النشطين';
  static const String statPendingAccounts = 'حسابات معلقة';
  static const String statSuspendedAccounts = 'حسابات معلقة';
  static const String statTotalRevenue = 'إجمالي الإيرادات';

  // Notification Target
  static const String targetAll = 'الجميع';
  static const String targetAllProviders = 'جميع المقدمين';
  static const String targetAllStudents = 'جميع الطلاب';
  static const String targetSpecific = 'حسابات محددة';
}
