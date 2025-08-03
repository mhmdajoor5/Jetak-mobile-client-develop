# Pusher Integration Guide

## إعدادات Pusher

### معلومات الاتصال:
```
app_id = "2016693"
key = "35debf4f355736840916"
secret = "0509c246c2d3e9a05ee3"
cluster = "ap2"
```

## التحديثات المطبقة

### 1. إضافة Pusher Package
```yaml
dependencies:
  pusher_client: ^2.0.0
```

### 2. تحديث Tracking Controller
- استبدال WebSocket المباشر بـ Pusher
- إضافة إعدادات Pusher
- تحسين معالجة الأحداث

### 3. إعدادات Pusher في الكود
```dart
static const String _pusherAppId = "2016693";
static const String _pusherKey = "35debf4f355736840916";
static const String _pusherSecret = "0509c246c2d3e9a05ee3";
static const String _pusherCluster = "ap2";
```

## كيفية الاستخدام

### 1. الاتصال بـ Pusher
```dart
trackingController.connectToDriverTracking(orderId);
```

### 2. اختبار الاتصال
```dart
await trackingController.testPusherConnection(orderId);
```

### 3. عرض معلومات التشخيص
```dart
trackingController.showDiagnosticInfo();
```

### 4. إغلاق الاتصال
```dart
trackingController.disconnectFromDriverTracking();
```

## الأحداث المدعومة

### 1. تحديث موقع السائق
```dart
_trackingChannel!.bind('driver-location-update', (event) {
  // معالجة تحديث موقع السائق
});
```

### 2. تحديث حالة الطلب
```dart
_trackingChannel!.bind('order-status-update', (event) {
  // معالجة تحديث حالة الطلب
});
```

### 3. أحداث الاشتراك
```dart
_trackingChannel!.bind('pusher:subscription_succeeded', (event) {
  // تم الاشتراك بنجاح
});

_trackingChannel!.bind('pusher:subscription_error', (event) {
  // خطأ في الاشتراك
});
```

## معالجة الأخطاء

### 1. أخطاء الاتصال
```dart
_pusherClient!.onError((error) {
  print("❌ خطأ في Pusher: $error");
  _handleConnectionError(error.toString(), orderId);
});
```

### 2. تغيير حالة الاتصال
```dart
_pusherClient!.onConnectionStateChange((state) {
  if (state.currentState == PusherConnectionState.CONNECTED) {
    // تم الاتصال بنجاح
  } else if (state.currentState == PusherConnectionState.DISCONNECTED) {
    // تم قطع الاتصال
  }
});
```

## تشخيص المشاكل

### 1. فحص إعدادات Pusher
```dart
print("🔑 إعدادات Pusher:");
print("   - App ID: $_pusherAppId");
print("   - Key: $_pusherKey");
print("   - Cluster: $_pusherCluster");
```

### 2. اختبار الاتصال
```dart
await trackingController.testPusherConnection(orderId);
```

### 3. مراقبة الـ Logs
ابحث عن الرسائل التالية:
- `🚀 بدء الاتصال بـ Pusher`
- `✅ تم الاتصال بـ Pusher بنجاح`
- `❌ خطأ في Pusher`
- `📨 حدث تحديث موقع السائق`
- `📨 حدث تحديث حالة الطلب`

## إعدادات الخادم

### 1. تأكد من إعداد Pusher في الخادم
- تثبيت Pusher package
- تكوين إعدادات Pusher
- إرسال الأحداث للـ channels الصحيحة

### 2. إعدادات Channel
```php
// مثال في PHP
$pusher = new Pusher\Pusher(
    '35debf4f355736840916', // key
    '0509c246c2d3e9a05ee3', // secret
    '2016693', // app_id
    ['cluster' => 'ap2']
);

// إرسال حدث تحديث موقع السائق
$pusher->trigger('order-tracking.123', 'driver-location-update', [
    'latitude' => 31.532640,
    'longitude' => 35.098614
]);

// إرسال حدث تحديث حالة الطلب
$pusher->trigger('order-tracking.123', 'order-status-update', [
    'status' => 'In Progress',
    'status_id' => '2'
]);
```

## استكشاف الأخطاء

### 1. مشاكل الاتصال
- تحقق من إعدادات Pusher
- تأكد من صحة الـ credentials
- فحص الاتصال بالإنترنت

### 2. مشاكل الاشتراك
- تأكد من صحة اسم الـ channel
- تحقق من إعدادات الـ channel في الخادم
- راجع logs الخادم

### 3. مشاكل الأحداث
- تأكد من إرسال الأحداث من الخادم
- تحقق من أسماء الأحداث
- راجع تنسيق البيانات

## نصائح مهمة

### 1. إدارة الاتصال
- إغلاق الاتصال عند إغلاق التطبيق
- إعادة الاتصال عند استئناف التطبيق
- معالجة أخطاء الاتصال

### 2. تحسين الأداء
- استخدام connection pooling
- تقليل عدد الاتصالات المتزامنة
- تنظيف الموارد بشكل صحيح

### 3. الأمان
- لا تعرض الـ secret في الكود
- استخدم environment variables
- تحقق من صحة البيانات الواردة

## اختبار الاتصال

### 1. اختبار من التطبيق
```dart
await trackingController.testPusherConnection('test123');
```

### 2. اختبار من الخادم
```bash
# اختبار إرسال حدث
curl -X POST \
  -H "Content-Type: application/json" \
  -d '{"name":"driver-location-update","data":{"latitude":31.532640,"longitude":35.098614}}' \
  "https://api-ap2.pusherapp.com/apps/2016693/events"
```

### 3. مراقبة الاتصال
- استخدم Pusher Debug Console
- راقب Network tab في DevTools
- تحقق من logs التطبيق

## الدعم

إذا واجهت مشاكل:
1. تحقق من إعدادات Pusher
2. راجع logs التطبيق والخادم
3. اختبر الاتصال باستخدام الأدوات المقدمة
4. راجع وثائق Pusher الرسمية 