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
      return Coupon(
        id: jsonMap?['id']?.toString() ?? '',
        code: jsonMap?['code']?.toString() ?? '',
        discount: (jsonMap?['discount'] as num?)?.toDouble() ?? 0.0,
        discountType: jsonMap?['discount_type']?.toString() ?? '',
        discountables: jsonMap?['discountables'] != null ? List<Discountable>.from(jsonMap!['discountables'].map((e) => Discountable.fromJSON(e))) : [],
        valid: jsonMap?['valid'] ?? false,
      );
    } catch (e) {
      print(e);
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
