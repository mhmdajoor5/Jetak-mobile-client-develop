import 'discountable.dart';

class Coupon {
  String? id;
  String? code;
  double? discount;
  String? discountType;
  List<Discountable> discountables;
  String? discountableId;
  bool enabled;
  bool valid;

  Coupon({this.id, this.code, this.discount, this.discountType, this.discountableId, this.enabled = true, this.valid = false, this.discountables = const []});

  factory Coupon.fromJSON(Map<String, dynamic>? jsonMap) {
    try {
      print('🎫 إنشاء كوبون من JSON: $jsonMap');
      
      // التحقق من تاريخ انتهاء الصلاحية
      bool isExpired = false;
      if (jsonMap?['expires_at'] != null) {
        try {
          DateTime expiryDate = DateTime.parse(jsonMap!['expires_at']);
          isExpired = DateTime.now().isAfter(expiryDate);
        } catch (e) {
          print('🎫 خطأ في تحليل تاريخ انتهاء الصلاحية: $e');
        }
      }
      
      Coupon coupon = Coupon(
        id: jsonMap?['id']?.toString() ?? '',
        code: jsonMap?['code']?.toString() ?? '',
        discount: (jsonMap?['discount'] as num?)?.toDouble() ?? 0.0,
        discountType: jsonMap?['discount_type']?.toString() ?? '',
        discountables: jsonMap?['discountables'] != null ? List<Discountable>.from(jsonMap!['discountables'].map((e) => Discountable.fromJSON(e))) : [],
        valid: (jsonMap?['enabled'] ?? jsonMap?['valid'] ?? false) && !isExpired, // استخدام enabled وعدم انتهاء الصلاحية
      );
      
      print('🎫 الكوبون المنشأ:');
      print('🎫 - ID: ${coupon.id}');
      print('🎫 - Code: ${coupon.code}');
      print('🎫 - Enabled: ${jsonMap?['enabled']}');
      print('🎫 - Valid: ${jsonMap?['valid']}');
      print('🎫 - Expires At: ${jsonMap?['expires_at']}');
      print('🎫 - Is Expired: $isExpired');
      print('🎫 - Final Valid: ${coupon.valid}');
      print('🎫 - Discount: ${coupon.discount}');
      print('🎫 - DiscountType: ${coupon.discountType}');
      print('🎫 - Discountables: ${coupon.discountables.length}');
      
      return coupon;
    } catch (e) {
      print('🎫 خطأ في إنشاء الكوبون: $e');
      return Coupon(id: '', code: '', discount: 0.0, discountType: '');
    }
  }

  Map<String, dynamic> toMap() {
    return {"id": id, "code": code, "discount": discount, "discount_type": discountType, "valid": valid, "discountables": discountables.map((e) => e.toMap()).toList()};
  }

  @override
  bool operator ==(Object other) => identical(this, other) || (other is Coupon && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
