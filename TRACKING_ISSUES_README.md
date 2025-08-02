# مشكلة "Tracking Unavailable" في صفحة Order History - الحل المحدث

## المشكلة
عند فتح صفحة order history والضغط على "View" لأي طلب، تظهر رسالة "Tracking Unavailable" بدلاً من عرض خريطة التتبع.

## الحل الجديد المطبق

### بدلاً من إظهار "Tracking Unavailable"، الآن:
1. **إذا كانت إحداثيات واحدة فقط متوفرة**: تعرض الخريطة مع العلامة المتوفرة فقط
2. **إذا كانت كلا الإحداثيات متوفرة**: تعرض الخريطة مع كلا العلامتين
3. **إذا لم تكن هناك أي إحداثيات**: تعرض رسالة خطأ واضحة

## التغييرات المطبقة

### 1. تحسين معالجة الإحداثيات في TrackingModernWidget
```dart
// تحقق من الإحداثيات المتوفرة
bool hasRestaurantCoords = restaurantLat != null && restaurantLng != null && 
                          restaurantLat != 0.0 && restaurantLng != 0.0;
bool hasClientCoords = clientLat != null && clientLng != null && 
                      clientLat != 0.0 && clientLng != 0.0;

// إذا لم تكن هناك أي إحداثيات متوفرة، اعرض رسالة خطأ
if (!hasRestaurantCoords && !hasClientCoords) {
  return Scaffold(
    body: _buildErrorView("No location data available for this order."),
  );
}

// إذا كانت هناك إحداثيات متوفرة، اعرض الخريطة بدون مسار
print("✅ Showing map with available coordinates:");
```

### 2. بناء العلامات المتوفرة فقط
```dart
// بناء العلامات المتوفرة فقط
Set<Marker> markers = {};

// إضافة علامة المطعم إذا كانت الإحداثيات متوفرة
if (hasRestaurantCoords) {
  markers.add(
    Marker(
      markerId: MarkerId('restaurant'),
      position: LatLng(restaurantLat!, restaurantLng!),
      infoWindow: InfoWindow(title: 'Restaurant'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    ),
  );
}

// إضافة علامة العميل إذا كانت الإحداثيات متوفرة
if (hasClientCoords) {
  markers.add(
    Marker(
      markerId: MarkerId('client'),
      position: LatLng(clientLat!, clientLng!),
      infoWindow: InfoWindow(title: 'Delivery Address'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
    ),
  );
}
```

### 3. حساب موقع الكاميرا بناءً على الإحداثيات المتوفرة
```dart
// حساب موقع الكاميرا بناءً على الإحداثيات المتوفرة
LatLng cameraTarget;
double zoom = 12;

if (hasRestaurantCoords && hasClientCoords) {
  // كلا الإحداثيات متوفرة - مركز بينهما
  cameraTarget = LatLng(
    (restaurantLat! + clientLat!) / 2,
    (restaurantLng! + clientLng!) / 2,
  );
  zoom = 12;
} else if (hasRestaurantCoords) {
  // إحداثيات المطعم فقط متوفرة
  cameraTarget = LatLng(restaurantLat!, restaurantLng!);
  zoom = 14;
} else {
  // إحداثيات العميل فقط متوفرة
  cameraTarget = LatLng(clientLat!, clientLng!);
  zoom = 14;
}
```

### 4. تخطي حساب المسار إذا لم تكن كلا الإحداثيات متوفرة
```dart
// تحقق من وجود كلا الإحداثيات لحساب المسار
bool hasRestaurantCoords = _con.restaurantLocation.latitude != 0.0 && 
                          _con.restaurantLocation.longitude != 0.0;
bool hasClientCoords = _con.clientLocation.latitude != 0.0 && 
                      _con.clientLocation.longitude != 0.0;

// إذا لم تكن كلا الإحداثيات متوفرة، تخطى حساب المسار
if (!hasRestaurantCoords || !hasClientCoords) {
  print("⚠️ Skipping route calculation - missing coordinates:");
  setState(() {
    _isLoadingRoute = false;
    _routeError = null;
  });
  return;
}
```

### 5. نفس التحسينات في صفحة tracking العادية
- نفس المنطق مطبق في `lib/src/pages/tracking.dart`
- معالجة الإحداثيات المتوفرة فقط
- عرض الخريطة بدون مسار إذا لم تكن كلا الإحداثيات متوفرة

## المزايا الجديدة

### 1. تجربة مستخدم أفضل
- لا تظهر "Tracking Unavailable" إلا إذا لم تكن هناك أي إحداثيات
- الخريطة تظهر حتى لو كانت إحداثيات واحدة فقط متوفرة

### 2. مرونة أكبر
- يعمل مع الطلبات القديمة التي قد لا تحتوي على إحداثيات كاملة
- يعمل مع الطلبات الجديدة التي تحتوي على إحداثيات كاملة

### 3. رسائل خطأ واضحة
- رسائل أكثر وضوحاً للمستخدم
- شرح أسباب المشكلة المحتملة

## كيفية الاختبار

### 1. اختبار مع إحداثيات كاملة
- تأكد من أن الطلب يحتوي على إحداثيات المطعم والعنوان
- يجب أن تظهر الخريطة مع كلا العلامتين

### 2. اختبار مع إحداثيات واحدة فقط
- جرب مع طلب يحتوي على إحداثيات العنوان فقط
- يجب أن تظهر الخريطة مع علامة العنوان فقط

### 3. اختبار مع إحداثيات المطعم فقط
- جرب مع طلب يحتوي على إحداثيات المطعم فقط
- يجب أن تظهر الخريطة مع علامة المطعم فقط

### 4. اختبار بدون إحداثيات
- جرب مع طلب لا يحتوي على أي إحداثيات
- يجب أن تظهر رسالة "No location data available for this order"

## ملفات تم تعديلها

1. `lib/src/pages/TrackingModernWidget.dart`
   - تحسين معالجة الإحداثيات
   - بناء العلامات المتوفرة فقط
   - حساب موقع الكاميرا بناءً على الإحداثيات المتوفرة

2. `lib/src/pages/tracking.dart`
   - نفس التحسينات في صفحة tracking العادية
   - معالجة الإحداثيات المتوفرة فقط

## ملاحظات مهمة

1. **الخريطة تظهر بدون مسار** إذا لم تكن كلا الإحداثيات متوفرة
2. **المسار يحسب فقط** إذا كانت كلا الإحداثيات متوفرة
3. **الخريطة تظهر** حتى لو كانت إحداثيات واحدة فقط متوفرة
4. **رسالة خطأ واضحة** فقط إذا لم تكن هناك أي إحداثيات 