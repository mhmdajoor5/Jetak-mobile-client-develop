# WebSocket Connection Troubleshooting Guide

## المشكلة الحالية
```
flutter: ❌ خطأ في WebSocket: WebSocketChannelException: WebSocketChannelException: SocketException: Operation timed out (OS Error: Operation timed out, errno = 60), address = carrytechnologies.co, port = 55074
```

## تحليل المشكلة

### ملاحظات مهمة:
1. **تغيير المنفذ**: الخطأ يظهر على منافذ مختلفة (54586, 55074) بينما الكود يحاول الاتصال على المنفذ 6001
2. **عدم استخدام Pusher**: الكود يستخدم WebSocket مباشرة وليس Pusher
3. **مشاكل الشبكة**: قد تكون هناك مشاكل في إعدادات الشبكة أو proxy

### الأسباب المحتملة:
1. **مشاكل في الخادم**: خادم WebSocket غير متاح على المنفذ 6001
2. **مشاكل في الشبكة**: proxy أو NAT يحول المنفذ
3. **مشاكل في إعدادات الجدار الناري**: حظر الاتصالات
4. **مشاكل في DNS**: عدم حل اسم النطاق بشكل صحيح
5. **مشاكل في التطبيق**: خطأ في كود الاتصال أو الـ channel

## الحلول المطبقة

### 1. إضافة URLs بديلة
```dart
static const List<String> _websocketUrls = [
  'ws://carrytechnologies.co:6001',
  'wss://carrytechnologies.co:6001',
  'ws://carrytechnologies.co:8080',
  'wss://carrytechnologies.co:8080',
];
```

### 2. تحسين التحقق من صحة البيانات
```dart
bool _isValidChannel(String orderId) {
  // التحقق من صحة orderId
  if (orderId.isEmpty) return false;
  if (orderId.length < 3) return false;
  if (orderId.contains(' ')) return false;
  return true;
}
```

### 3. إضافة فحص صحة الخادم
```dart
Future<bool> checkServerHealth() async {
  // فحص جميع URLs المتاحة
  for (int i = 0; i < _websocketUrls.length; i++) {
    // محاولة الاتصال بـ HTTP للتحقق
  }
}
```

### 4. تنظيف orderId
```dart
final cleanOrderId = orderId.trim().replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '');
```

## كيفية الاستخدام الجديدة

### 1. الاتصال مع التحقق من صحة البيانات
```dart
trackingController.connectToDriverTrackingWithValidation(orderId);
```

### 2. الاتصال مع URLs بديلة
```dart
trackingController.connectToDriverTrackingWithFallback(orderId);
```

### 3. اختبار شامل مع فحص صحة الخادم
```dart
await trackingController.testConnectionWithServerHealth(orderId);
```

### 4. فحص صحة الخادم فقط
```dart
bool isHealthy = await trackingController.checkServerHealth();
```

## خطوات التشخيص المحسنة

### 1. فحص الخادم
```bash
# فحص المنفذ 6001
telnet carrytechnologies.co 6001

# فحص المنفذ 8080
telnet carrytechnologies.co 8080

# فحص HTTP
curl -I http://carrytechnologies.co
```

### 2. فحص DNS
```bash
nslookup carrytechnologies.co
dig carrytechnologies.co
```

### 3. فحص المسار
```bash
traceroute carrytechnologies.co
```

### 4. فحص المنافذ المفتوحة
```bash
nmap -p 6001,8080 carrytechnologies.co
```

## إعدادات الشبكة المطلوبة

### Android
- `INTERNET` permission ✅
- `ACCESS_NETWORK_STATE` permission ✅
- `usesCleartextTraffic="true"` ✅

### iOS
- Network permissions in Info.plist ✅
- Allow arbitrary loads ✅

## نصائح إضافية

### 1. للبيئة المحلية
- تأكد من أن الخادم يعمل على المنافذ المطلوبة
- تحقق من إعدادات الجدار الناري
- جرب الاتصال من terminal

### 2. للبيئة الإنتاجية
- تحقق من إعدادات الخادم
- تأكد من فتح المنافذ المطلوبة
- راجع logs الخادم

### 3. للشبكات المحمية
- تحقق من إعدادات proxy
- راجع إعدادات VPN
- تأكد من عدم حظر WebSocket

## مراقبة الاتصال المحسنة

### في التطبيق
```dart
// فحص حالة الاتصال
trackingController.checkWebSocketStatus();

// مراقبة الأخطاء
trackingController.diagnoseConnectionIssues();

// فحص صحة الخادم
await trackingController.checkServerHealth();
```

### في Logs
ابحث عن الرسائل التالية:
- `🚀 بدء الاتصال بـ WebSocket`
- `✅ تم الاتصال بـ WebSocket بنجاح`
- `❌ خطأ في WebSocket`
- `🔄 محاولة إعادة الاتصال`
- `🏥 فحص صحة الخادم`
- `🔍 التحقق من صحة البيانات`

## استكشاف الأخطاء المحسن

### إذا كان الاتصال بالإنترنت متاح:
1. تحقق من حالة الخادم باستخدام `checkServerHealth()`
2. فحص المنافذ المطلوبة
3. راجع إعدادات الجدار الناري

### إذا كان الخادم متاح:
1. تحقق من إعدادات WebSocket
2. راجع logs الخادم
3. تأكد من صحة الـ channel

### إذا كان كل شيء متاح:
1. تحقق من كود الاتصال
2. راجع إعدادات التطبيق
3. جرب إعادة تشغيل التطبيق

## اختبار الاتصال

### 1. اختبار شامل
```dart
await trackingController.testConnectionWithServerHealth(orderId);
```

### 2. اختبار URLs بديلة
```dart
trackingController.connectToDriverTrackingWithFallback(orderId);
```

### 3. اختبار مع التحقق من صحة البيانات
```dart
trackingController.connectToDriverTrackingWithValidation(orderId);
```

## الدعم

إذا استمرت المشكلة:
1. جمع logs التطبيق
2. فحص logs الخادم
3. اختبار الاتصال من terminal
4. مراجعة إعدادات الشبكة
5. استخدام الدوال الجديدة للتشخيص

## ملاحظات مهمة

1. **تأكد من صحة orderId**: يجب أن يكون صحيحاً وليس فارغاً
2. **فحص الخادم**: استخدم `checkServerHealth()` قبل الاتصال
3. **استخدام URLs بديلة**: جرب جميع URLs المتاحة
4. **مراقبة Logs**: راقب الرسائل في console للتشخيص 