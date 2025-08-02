# ميزة تعطيل/تشغيل التطبيق

## نظرة عامة

تم إضافة ميزة جديدة للتحكم في حالة التطبيق (متاح/معطل) من خلال قاعدة البيانات، مما يسمح بإيقاف التطبيق مؤقتاً دون الحاجة لتحديث الكود أو نشر إصدار جديد.

## الميزات

- ✅ **التحكم المركزي**: إدارة حالة التطبيق من قاعدة البيانات
- ✅ **رسائل مخصصة**: إمكانية تخصيص رسالة الصيانة
- ✅ **فحص تلقائي**: التحقق من حالة التطبيق عند بدء التشغيل
- ✅ **إعادة المحاولة**: زر لإعادة فحص حالة التطبيق
- ✅ **دعم متعدد اللغات**: رسائل مترجمة للعربية والإنجليزية
- ✅ **واجهة جميلة**: تصميم عصري لصفحة الصيانة

## كيفية الاستخدام

### 1. إعداد قاعدة البيانات

أضف الحقول التالية إلى جدول الإعدادات في قاعدة البيانات:

```sql
ALTER TABLE settings ADD COLUMN app_status TINYINT(1) DEFAULT 1;
ALTER TABLE settings ADD COLUMN maintenance_message TEXT DEFAULT 'التطبيق حالياً غير متاح. يرجى المحاولة لاحقاً.';
```

### 2. التحكم في حالة التطبيق

#### تفعيل التطبيق (متاح):
```sql
UPDATE settings SET app_status = 1;
```

#### تعطيل التطبيق (معطل):
```sql
UPDATE settings SET app_status = 0;
```

#### تخصيص رسالة الصيانة:
```sql
UPDATE settings SET maintenance_message = 'رسالة مخصصة للصيانة';
```

### 3. API Endpoint

يمكن التحكم في الإعدادات من خلال API endpoint:

```
GET /api/settings
```

الاستجابة ستتضمن الحقول الجديدة:
```json
{
  "success": true,
  "data": {
    "app_name": "Jetak",
    "app_status": "1",
    "maintenance_message": "التطبيق حالياً غير متاح. يرجى المحاولة لاحقاً.",
    // ... باقي الإعدادات
  }
}
```

## كيفية عمل الميزة

### 1. بدء التطبيق
عند فتح التطبيق، يتم التحقق من حالة التطبيق في `SplashScreen`:

```dart
Future<void> _checkAppStatus() async {
  // تحميل الإعدادات من السيرفر
  await settingRepo.initSettings();
  
  // التحقق من حالة التطبيق
  if (!settingRepo.setting.value.appStatus) {
    // التطبيق معطل، الانتقال لصفحة الصيانة
    Navigator.of(context).pushReplacementNamed('/Maintenance');
  }
}
```

### 2. صفحة الصيانة
إذا كان التطبيق معطلاً، سيتم عرض صفحة الصيانة مع:
- رسالة مخصصة من قاعدة البيانات
- زر إعادة المحاولة
- تصميم جميل ومتجاوب

### 3. إعادة المحاولة
يمكن للمستخدم الضغط على زر "إعادة المحاولة" للتحقق من حالة التطبيق مرة أخرى.

## الملفات المضافة/المحدثة

### ملفات جديدة:
- `lib/src/pages/maintenance_page.dart` - صفحة الصيانة
- `APP_MAINTENANCE_README.md` - هذا الملف

### ملفات محدثة:
- `lib/src/models/setting.dart` - إضافة حقول حالة التطبيق
- `lib/src/pages/splash_screen.dart` - إضافة فحص حالة التطبيق
- `lib/route_generator.dart` - إضافة مسار صفحة الصيانة
- `lib/l10n/intl_ar.arb` - إضافة الترجمات العربية
- `lib/l10n/intl_en.arb` - إضافة الترجمات الإنجليزية

## الترجمات المضافة

### العربية:
```json
{
  "app_maintenance_title": "التطبيق غير متاح حالياً",
  "app_maintenance_message": "التطبيق حالياً غير متاح. يرجى المحاولة لاحقاً.",
  "retry_button": "إعادة المحاولة",
  "checking_status": "جاري التحقق...",
  "app_will_be_back_soon": "سيتم إعادة تفعيل التطبيق قريباً",
  "app_still_unavailable": "التطبيق لا يزال غير متاح",
  "server_connection_error": "خطأ في الاتصال بالخادم"
}
```

### الإنجليزية:
```json
{
  "app_maintenance_title": "App Unavailable",
  "app_maintenance_message": "The app is currently unavailable. Please try again later.",
  "retry_button": "Retry",
  "checking_status": "Checking...",
  "app_will_be_back_soon": "The app will be back soon",
  "app_still_unavailable": "App is still unavailable",
  "server_connection_error": "Server connection error"
}
```

## سيناريوهات الاستخدام

### 1. صيانة مجدولة
```sql
-- تعطيل التطبيق قبل الصيانة
UPDATE settings SET app_status = 0, maintenance_message = 'سيتم إجراء صيانة مجدولة من الساعة 2:00 صباحاً حتى 4:00 صباحاً';

-- إعادة تفعيل التطبيق بعد الصيانة
UPDATE settings SET app_status = 1;
```

### 2. مشاكل في السيرفر
```sql
-- تعطيل التطبيق عند وجود مشاكل
UPDATE settings SET app_status = 0, maintenance_message = 'نواجه مشاكل تقنية مؤقتة. نعتذر عن الإزعاج وسنعود قريباً.';
```

### 3. تحديثات مهمة
```sql
-- تعطيل التطبيق للتحديثات
UPDATE settings SET app_status = 0, maintenance_message = 'نقوم بتحديث التطبيق لتحسين الخدمة. سنعود خلال 30 دقيقة.';
```

## ملاحظات مهمة

1. **الأمان**: تأكد من حماية API endpoint للتحكم في الإعدادات
2. **النسخ الاحتياطية**: احتفظ بنسخة احتياطية من الإعدادات قبل التعديل
3. **الاختبار**: اختبر الميزة في بيئة التطوير قبل الإنتاج
4. **المراقبة**: راقب حالة التطبيق بعد التفعيل/التعطيل

## الدعم

إذا واجهت أي مشاكل أو لديك أسئلة حول هذه الميزة، يرجى التواصل مع فريق التطوير. 