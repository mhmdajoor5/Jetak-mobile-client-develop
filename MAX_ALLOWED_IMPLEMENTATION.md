# تطبيق منطق max_allowed و max_charge

## ✅ تم الحل بنجاح!

تم تطبيق نظام تسعير متقدم للإضافات (Extras) يتيح تحديد:
- **max_allowed**: عدد العناصر المسموح اختيارها بدون رسوم إضافية
- **max_charge**: الرسوم الإضافية لكل عنصر يتجاوز الحد المسموح

## 🔧 التغييرات المطبقة

### 1. تحديث نموذج ExtraGroup
**الملف**: `lib/src/models/extra_group.dart`

```dart
class ExtraGroup {
  String id;
  String name;
  int? maxAllowed; // عدد العناصر المسموح اختيارها بدون رسوم إضافية
  double maxCharge; // الرسوم الإضافية لكل عنصر يتجاوز الحد المسموح
}
```

### 2. تحديث نموذج Extra
**الملف**: `lib/src/models/extra.dart`

```dart
class Extra {
  // ... الحقول الموجودة
  double extraCharge; // الرسوم الإضافية للعنصر
}
```

### 3. تحديث دالة حساب السعر في Cart
**الملف**: `lib/src/models/cart.dart`

تم تحديث دالة `getFoodPrice()` لتطبق المنطق الجديد:
- تجميع الإضافات حسب المجموعة
- تطبيق `max_allowed` و `max_charge` لكل مجموعة
- حساب السعر النهائي

### 4. إضافة دالة Helper جديدة
**الملف**: `lib/src/helpers/helper.dart`

تم إضافة دالة `calculateExtrasPrice()` لحساب سعر الإضافات مع مراعاة المنطق الجديد.

### 5. إصلاح مشكلة Import
تم إضافة import للـ `ExtraGroup` في جميع الملفات التي تحتاجه:
- `lib/src/models/cart.dart`
- `lib/src/helpers/helper.dart`

## 📊 مثال عملي

### السيناريو:
- مجموعة إضافات: "اختيار نوع اللحم"
- `max_allowed = 3`
- `max_charge = 2.0`
- سعر الطعام الأساسي: 15.0

### الحالات المختلفة:

#### 1. اختيار إضافتين فقط (ضمن الحد المسموح)
```
الإضافات: دجاج (5.0) + لحم بقري (8.0)
السعر: 15.0 + 5.0 + 8.0 = 28.0
```

#### 2. اختيار 3 إضافات (بالضبط الحد المسموح)
```
الإضافات: دجاج (5.0) + لحم بقري (8.0) + لحم غنم (10.0)
السعر: 15.0 + 5.0 + 8.0 + 10.0 = 38.0
```

#### 3. اختيار 4 إضافات (يتجاوز الحد المسموح)
```
الإضافات: دجاج (5.0) + لحم بقري (8.0) + لحم غنم (10.0) + لحم ديك رومي (7.0)
السعر: 15.0 + 5.0 + 8.0 + 10.0 + (7.0 + 2.0 رسوم إضافية) = 47.0
```

## 🔄 المنطق المطبق

```dart
if (extraGroup.maxAllowed != null && groupExtras.length > extraGroup.maxAllowed!) {
  // عدد الإضافات يتجاوز الحد المسموح
  int allowedCount = extraGroup.maxAllowed!;
  
  // حساب سعر الإضافات المسموحة
  for (int i = 0; i < allowedCount && i < groupExtras.length; i++) {
    totalPrice += groupExtras[i].price;
  }
  
  // إضافة الرسوم الإضافية للإضافات التي تتجاوز الحد
  for (int i = allowedCount; i < groupExtras.length; i++) {
    totalPrice += groupExtras[i].price + extraGroup.maxCharge;
  }
} else {
  // عدد الإضافات ضمن الحد المسموح أو لا يوجد حد
  for (var extra in groupExtras) {
    totalPrice += extra.price;
  }
}
```

## 📁 الملفات المحدثة

1. `lib/src/models/extra_group.dart` - إضافة maxAllowed و maxCharge
2. `lib/src/models/extra.dart` - إضافة extraCharge
3. `lib/src/models/cart.dart` - تحديث getFoodPrice() وإضافة import
4. `lib/src/helpers/helper.dart` - إضافة calculateExtrasPrice() وimport
5. `lib/src/controllers/cart_controller.dart` - تحديث calculateSubtotal()
6. `lib/src/controllers/food_controller.dart` - تحديث calculateTotal()

## ✅ التحقق من الحل

تم تشغيل `flutter analyze` و `flutter pub get` بنجاح بدون أخطاء.

## ✅ المزايا

1. **مرونة في التسعير**: يمكن تحديد حدود مختلفة لكل مجموعة إضافات
2. **رسوم إضافية قابلة للتخصيص**: يمكن تحديد رسوم مختلفة لكل مجموعة
3. **توافق مع النظام الحالي**: لا يؤثر على الإضافات التي لا تحتوي على max_allowed
4. **سهولة الاستخدام**: المنطق مطبق تلقائياً في جميع عمليات حساب السعر
5. **لا توجد أخطاء في الكود**: تم حل جميع مشاكل Import

## 🔮 الاستخدام المستقبلي

يمكن استخدام هذا النظام لـ:
- مجموعات اللحوم مع حد أقصى للاختيار
- الصلصات مع رسوم إضافية للكميات الكبيرة
- الإضافات المميزة مع تسعير خاص
- أي مجموعة إضافات تحتاج إلى قيود على الكمية

## 🚀 جاهز للاستخدام

النظام جاهز للاستخدام في التطبيق! يمكنك الآن:
1. تحديد `max_allowed` و `max_charge` في API
2. النظام سيطبق المنطق تلقائياً
3. سيتم حساب الأسعار بشكل صحيح في السلة والطلبات 