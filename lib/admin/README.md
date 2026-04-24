# وصلة - المشرف / Wasla Admin

تطبيق إدارة المنصة في منصة وصلة. يتيح للمشرفين مراقبة النظام، إدارة المستخدمين، المواد الدراسية، التحقق من الحجوزات، مراجعة التقارير، وإدارة المحتوى.

The admin management app for the Wasla educational platform. It enables administrators to monitor the system, manage users and subjects, verify bookings, review reports, and manage content.

---

## الميزات / Features

- **لوحة التحكم الرئيسية**: نظرة شاملة على إحصائيات المنصة (عدد المستخدمين، الحجوزات، الإيرادات)
- **إدارة المزودين**: عرض ومراجعة طلبات التسجيل، تفعيل/تعليق حسابات المزودين
- **إدارة الطلاب**: عرض قائمة الطلاب وإدارة حساباتهم
- **إدارة المواد الدراسية**: إضافة/تعديل/حذف التصنيفات والمواد
- **مراقبة الحجوزات**: عرض جميع الحجوزات والتحقق من حالتها
- **إدارة التقارير**: عرض البلاغات والتقييمات المسيئة
- **الإحصائيات والتقارير**: تقارير مفصلة عن أداء المنصة والمالية
- **إدارة الإشعارات**: إرسال إشعارات عامة لمستخدمي المنصة
- **إدارة المحتوى**: مراجعة وإدارة المرفقات والملفات المرفوعة

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
wasla_admin/
├── android/                    # إعدادات Android
│   ├── app/
│   │   ├── build.gradle.kts   # إعدادات Gradle للتطبيق
│   │   └── src/main/
│   │       ├── AndroidManifest.xml
│   │       └── kotlin/com/wasla/admin/
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
│   │   ├── auth/              # تسجيل دخول المشرف
│   │   ├── dashboard/         # لوحة التحكم الرئيسية
│   │   ├── providers/         # إدارة المزودين
│   │   ├── students/          # إدارة الطلاب
│   │   ├── subjects/          # إدارة المواد الدراسية
│   │   ├── bookings/          # مراقبة الحجوزات
│   │   ├── reports/           # إدارة التقارير
│   │   ├── statistics/        # الإحصائيات
│   │   ├── notifications/     # إدارة الإشعارات
│   │   └── content/           # إدارة المحتوى
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
