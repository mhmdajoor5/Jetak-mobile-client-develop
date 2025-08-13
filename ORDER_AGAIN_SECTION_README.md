# قسم إعادة الطلب (Order Again Section)

## نظرة عامة
تم إضافة قسم "إعادة الطلب" إلى الصفحة الرئيسية للتطبيق، والذي يعرض الطلبات السابقة للمستخدم مع إمكانية إعادة الطلب بسهولة.

## الميزات

### 🔹 عرض الطلبات السابقة
- يعرض الطلبات السابقة مجمعة حسب المطعم/المتجر
- يظهر عدد الطلبات السابقة لكل مطعم
- يعرض تاريخ آخر طلب بتنسيق مقروء (اليوم، أمس، منذ X أيام، إلخ)

### 🔹 واجهة مستخدم محسنة
- تصميم بطاقات أفقية قابلة للتمرير
- صور المطاعم مع معالجة الأخطاء
- أزرار "إعادة الطلب" واضحة وسهلة الاستخدام
- دعم اللغة العربية والإنجليزية

### 🔹 تجربة مستخدم سلسة
- الانتقال المباشر إلى صفحة المطعم عند النقر
- إعادة الطلب بنقرة واحدة
- عرض حالة فارغة عندما لا توجد طلبات سابقة

## الملفات المضافة/المعدلة

### ملفات جديدة:
- `lib/src/pages/Home/home_order_again_section.dart` - القسم الرئيسي

### ملفات معدلة:
- `lib/src/pages/bottom_nav_bar_modules/home.dart` - إضافة القسم إلى الصفحة الرئيسية

## كيفية الاستخدام

### إضافة القسم إلى الصفحة الرئيسية:
```dart
// في home.dart
case 'order_again':
  return HomeOrderAgainSection();
```

### إضافة القسم كخيار في الإعدادات:
يمكن إضافة `'order_again'` إلى قائمة `homeSections` في إعدادات التطبيق.

## التصميم

### الألوان المستخدمة:
- النص الرئيسي: `Color(0xFF1A1A1A)` (أسود غامق)
- النص الثانوي: `Color(0xFF666666)` (رمادي متوسط)
- النص الثالث: `Color(0xFF888888)` (رمادي فاتح)
- خلفية البطاقة: `Colors.white` (أبيض)
- لون الزر: `Color(0xFF2196F3)` (أزرق جميل)
- حدود البطاقة: `Colors.grey.withValues(alpha: 0.1)` (رمادي شفاف)

### الأبعاد:
- ارتفاع القسم: 280px
- عرض البطاقة: 160px
- ارتفاع الصورة: 150px (مثل Most Popular)

## الوظائف الرئيسية

### `_buildOrdersList()`
يعرض قائمة الطلبات السابقة مجمعة حسب المطعم.

### `_formatOrderDate(DateTime dateTime)`
يقوم بتنسيق تاريخ الطلب إلى نص مقروء.

### `_navigateToRestaurant(String restaurantId, String restaurantName)`
ينتقل إلى صفحة تفاصيل المطعم.

### `_reorderFromRestaurant(String restaurantId, String restaurantName)`
يفتح صفحة المطعم لإعادة الطلب.

## معالجة الحالات

### حالة عدم وجود طلبات:
```dart
Widget _buildEmptyState() {
  return Container(
    height: 150,
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 50, color: Colors.grey[400]),
          Text('لا توجد طلبات سابقة'),
          Text('ابدأ بالطلب من المطاعم والمتاجر'),
        ],
      ),
    ),
  );
}
```

### معالجة أخطاء الصور:
```dart
Widget _buildDefaultRestaurantImage() {
  return Container(
    height: 100,
    color: Colors.grey[300],
    child: Icon(Icons.restaurant, color: Colors.grey[600], size: 40),
  );
}
```

## التحديثات المستقبلية

### تحسينات مقترحة:
1. إضافة فلترة للطلبات (حسب التاريخ، المطعم، إلخ)
2. إضافة إحصائيات أكثر تفصيلاً
3. إمكانية إعادة طلب منتجات محددة
4. إضافة تقييمات للطلبات السابقة
5. إشعارات للعروض الخاصة من المطاعم السابقة

### تحسينات الأداء:
1. تخزين مؤقت للطلبات السابقة
2. تحميل تدريجي للصور
3. تحسين استعلامات قاعدة البيانات

## استكشاف الأخطاء

### تحسينات التصميم:
تم تحديث قسم "إعادة الطلب" ليستخدم نفس الكومبنت (GridCardWidget) المستخدم في البطاقة الثانية:
- استخدام GridCardWidget مباشرة بدلاً من إعادة كتابة التصميم
- نفس التصميم والأبعاد والوظائف
- نفس معالجة الصور والخصومات
- نفس التخطيط والألوان
- إزالة الكود المكرر وتقليل حجم الملف

### التطابق التام:
تم إعادة GridCardWidget إلى حالته الأصلية كما كان في Most Popular:
- ارتفاع الصورة: 150px (كما كان)
- المساحات الداخلية: 10px (كما كان)
- أحجام الخطوط: 14px و 12px (كما كان)
- أحجام الأيقونات: 16px (كما كان)
- ارتفاع السطور: 1.3 و 1.6 (كما كان)

### الإصلاحات المطبقة:
```dart
// استخدام GridCardWidget مباشرة
import '../../elements/grid_card_widget.dart';

// في _buildOrdersList()
Restaurant? restaurant;
if (latestOrder.restaurant != null) {
  restaurant = latestOrder.restaurant!;
} else if (latestOrder.foodOrders.isNotEmpty && 
           latestOrder.foodOrders.first.food?.restaurant != null) {
  restaurant = latestOrder.foodOrders.first.food!.restaurant!;
}

if (restaurant == null) {
  return SizedBox.shrink();
}

return Container(
  width: 160,
  margin: EdgeInsets.only(right: 15),
  child: GridCardWidget(restaurant: restaurant),
);

// إعادة GridCardWidget إلى حالته الأصلية:
// - height: 150 (كما كان في Most Popular)
// - padding: vertical: 10 (كما كان)
// - fontSize: 14, 12 (كما كان)
// - icon size: 16 (كما كان)
// - line height: 1.3, 1.6 (كما كان)

// إزالة الكود المكرر:
// - _buildDefaultRestaurantImage()
// - _formatOrderDate()
// - _navigateToRestaurant()
// - _reorderFromRestaurant()
```

### مشكلة عدم ظهور الطلبات:
تأكد من:
- وجود مستخدم مسجل دخول
- وجود طلبات سابقة في قاعدة البيانات
- صحة API endpoints

## المساهمة

لإضافة تحسينات أو إصلاح مشاكل:
1. قم بإنشاء branch جديد
2. أضف التحديثات
3. اختبر التطبيق
4. قم بإنشاء pull request

## الدعم

للمساعدة أو الإبلاغ عن مشاكل، يرجى التواصل مع فريق التطوير. 