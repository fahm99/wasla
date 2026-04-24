# وصلة أكاديمي / Wasla Student

تطبيق الطلاب في منصة وصلة. يتيح للطلاب البحث عن مقدمي خدمات تعليمية، تصفح المواد الدراسية، حجز الحصص، التواصل مع المزودين، وتقييم الخدمات.

The student app for the Wasla educational platform. It enables students to search for educational service providers, browse subjects, book lessons, communicate with providers, and rate services.

---

## الميزات / Features

- **تسجيل الدخول والتسجيل**: إنشاء حساب طالب جديد أو تسجيل الدخول ببريد إلكتروني وكلمة مرور
- **التصفح والبحث**: البحث عن مقدمي الخدمات حسب التخصص، المادة، أو الموقع
- **عرض الملف الشخصي للمزود**: رؤية تفاصيل المزود، تقييماته، المواد المقدمة
- **حجز الحصص**: اختيار حصة وتأكيد الحجز مع تحديد الموعد
- **التواصل**: محادثة مباشرة مع مقدمي الخدمات عبر نظام الرسائل
- **التقييم**: تقييم مقدمي الخدمات بعد كل حصة
- **لوحة التحكم**: متابعة الحصص القادمة، الحصص المكتملة، والإحصائيات
- **الإشعارات**: استقبال إشعارات بتأكيد الحجوزات والتذكيرات
- **رفع المرفقات**: رفع الواجبات والملفات المطلوبة

---

## الإعداد / Setup

### 1. تثبيت المكتبات / Install Dependencies

```bash
flutter pub get
```

### 2. إعداد Supabase / Configure Supabase

افتح ملف `lib/config/supabase_config.dart` (أو `lib/core/constants.dart`) وحدّث البيانات التالية:

Open `lib/config/supabase_config.dart` (or `lib/core/constants.dart`) and update:

```dart
class SupabaseConfig {
  static const String supabaseUrl = 'https://YOUR_PROJECT_ID.supabase.co';
  static const String supabaseAnonKey = 'YOUR_ANON_KEY';
}
```

استبدل `YOUR_PROJECT_ID` و `YOUR_ANON_KEY` ببيانات مشروعك من [Supabase Dashboard](https://supabase.com/dashboard) > **Project Settings > API**.

Replace `YOUR_PROJECT_ID` and `YOUR_ANON_KEY` with your project credentials from the [Supabase Dashboard](https://supabase.com/dashboard) > **Project Settings > API**.

---

## التشغيل / Run

### تشغيل على جهاز Android:

```bash
flutter run
# أو تحديداً
flutter run -d android
```

### تشغيل على جهاز iOS:

```bash
flutter run -d ios
# أو محاكي iOS
flutter run -d iPhone
```

### تشغيل على الويب (للتطوير):

```bash
flutter run -d chrome
```

---

## هيكل المجلدات / Folder Structure

```
wasla_student/
├── android/                    # إعدادات Android
│   ├── app/
│   │   ├── build.gradle.kts   # إعدادات Gradle للتطبيق
│   │   └── src/main/
│   │       ├── AndroidManifest.xml
│   │       └── kotlin/com/wasla/student/
│   │           └── MainActivity.kt
│   ├── build.gradle.kts       # إعدادات Gradle للمشروع
│   ├── settings.gradle.kts    # إعدادات المستودعات والمكونات
│   ├── gradle.properties      # خصائص Gradle
│   └── local.properties       # مسار Flutter SDK محلي
├── ios/                        # إعدادات iOS
│   └── Runner/
│       └── Info.plist         # إعدادات تطبيق iOS
├── lib/                        # الكود المصدري
│   ├── main.dart              # نقطة الدخول
│   ├── config/                # إعدادات التطبيق (Supabase, etc.)
│   ├── core/                  # مكونات أساسية (ثوابت، أدوات مساعدة)
│   ├── features/              # ميزات التطبيق
│   │   ├── auth/              # تسجيل الدخول والتسجيل
│   │   ├── home/              # الصفحة الرئيسية والبحث
│   │   ├── provider/          # عرض ملف المزود
│   │   ├── booking/           # حجز الحصص
│   │   ├── my_bookings/       # حجوزاتي
│   │   ├── chat/              # المحادثات
│   │   ├── reviews/           # التقييمات
│   │   ├── notifications/     # الإشعارات
│   │   └── profile/           # الملف الشخصي
│   ├── models/                # نماذج البيانات
│   ├── services/              # الخدمات (API calls, etc.)
│   └── widgets/               # مكونات واجهة المستخدم
├── assets/                     # الموارد (صور، خطوط، إلخ)
├── pubspec.yaml               # مكتبات المشروع
└── README.md                  # هذا الملف
```

---

## المتطلبات / Requirements

- **Flutter**: SDK >= 3.16.0
- **Android**: minSdk 21, targetSdk 34
- **iOS**: iOS 12.0+
- **Supabase**: حساب نشط مع مشروع مُجهّز
