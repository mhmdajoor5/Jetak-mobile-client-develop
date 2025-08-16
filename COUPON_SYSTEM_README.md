# نظام الكوبون - Coupon System

## ✅ الميزات المطبقة:

### 1. **تطبيق الكوبون من API**
- جلب بيانات الكوبون من الخادم عبر `verifyCoupon()`
- التحقق من صحة الكوبون (`valid`)
- التحقق من أن الكوبون ينطبق على المطعم الحالي

### 2. **حساب الخصم بشكل صحيح**
- **خصم ثابت (Fixed)**: خصم مبلغ محدد (مثل 5 دينار)
- **خصم نسبي (Percent)**: خصم نسبة مئوية (مثل 10%)
- التأكد من أن الخصم لا يتجاوز السعر الإجمالي

### 3. **واجهة المستخدم**
- حقل إدخال الكوبون في صفحة Delivery/Pickup
- عرض الكوبون المطبق مع إمكانية إزالته
- رسائل تأكيد وأخطاء واضحة

### 4. **عرض الخصم في Order Summary**
- إظهار "خصم الكوبون" في ملخص الطلب
- عرض قيمة الخصم ونوعه (ثابت أو نسبي)

## 📁 الملفات المحدثة:

### 1. **`lib/src/controllers/cart_controller.dart`**
```dart
// حساب الخصم في calculateSubtotal()
double couponDiscount = 0.0;
if (coupon.valid == true && coupon.discount != null) {
  if (coupon.discountType == 'fixed') {
    couponDiscount = coupon.discount!;
  } else if (coupon.discountType == 'percent') {
    couponDiscount = subTotal * (coupon.discount! / 100);
  }
  // التأكد من أن الخصم لا يتجاوز السعر الإجمالي
  if (couponDiscount > subTotal) {
    couponDiscount = subTotal;
  }
}

// تطبيق الكوبون من API
void doApplyCoupon(String code) async {
  // جلب بيانات الكوبون من API
  Stream<Coupon> couponStream = await verifyCoupon(code);
  
  // التحقق من صحة الكوبون
  // التحقق من تطبيق الكوبون على المطعم الحالي
  // تطبيق الخصم
}
```

### 2. **`lib/src/pages/delivery_pickup.dart`**
- حقل إدخال الكوبون مع زر التطبيق
- عرض الكوبون المطبق
- إدارة حالة التحميل

### 3. **`lib/src/elements/CartBottomDetailsWidget.dart`**
- عرض "خصم الكوبون" في ملخص الطلب

### 4. **`lib/src/models/order.dart`**
- إضافة `Coupon? coupon` للطلب
- إرسال `coupon_code` للخادم

## 🔧 كيفية الاستخدام:

### 1. **تطبيق الكوبون:**
```
1. انتقل إلى صفحة Delivery/Pickup
2. ابحث عن حقل "Add a promo code"
3. أدخل رمز الكوبون
4. اضغط "تطبيق" أو Enter
5. انتظر التحقق من API
6. شاهد الخصم في Order Summary
```

### 2. **إزالة الكوبون:**
```
اضغط على زر "إزالة" بجانب الكوبون المطبق
```

## 🎯 منطق العمل:

### 1. **التحقق من الكوبون:**
```dart
// جلب من API
Stream<Coupon> couponStream = await verifyCoupon(code);

// التحقق من الصحة
if (!foundCoupon.valid!) return;

// التحقق من المطعم
bool isValidForRestaurant = foundCoupon.discountables!.any((discountable) =>
  discountable.discountableType == 'App\\Models\\Restaurant' &&
  discountable.discountableId.toString() == currentRestaurantId
);
```

### 2. **حساب الخصم:**
```dart
if (coupon.discountType == 'fixed') {
  couponDiscount = coupon.discount!; // خصم ثابت
} else if (coupon.discountType == 'percent') {
  couponDiscount = subTotal * (coupon.discount! / 100); // خصم نسبي
}
```

### 3. **تطبيق الخصم:**
```dart
total = subTotal + deliveryFee - couponDiscount;
```

## 🚨 رسائل الخطأ:

- **"كوبون غير صالح"**: الكوبون غير موجود أو غير فعال
- **"هذا الكوبون لا ينطبق على المطعم الحالي"**: الكوبون لمطعم آخر
- **"حدث خطأ في تطبيق الكوبون"**: مشكلة في الاتصال بالخادم

## ✅ رسائل النجاح:

- **"تم تطبيق الكوبون بنجاح! خصم X دينار"**: للخصم الثابت
- **"تم تطبيق الكوبون بنجاح! خصم X%"**: للخصم النسبي

## 🔄 حل مشاكل الترجمة:

إذا واجهت أخطاء في الترجمة، قم بتشغيل:
```bash
flutter packages pub run intl_utils:generate
```

## 📊 اختبار النظام:

1. **كوبون صحيح**: يجب أن يطبق الخصم
2. **كوبون خاطئ**: يجب أن يظهر رسالة خطأ
3. **كوبون لمطعم آخر**: يجب أن يظهر رسالة عدم التطبيق
4. **إزالة الكوبون**: يجب أن يختفي الخصم

النظام جاهز للاستخدام! 🚀
