import '../helpers/custom_trace.dart';
import 'coupon.dart';

class Discountable {
  String id;
  String? discountableType;
  String? discountableId;
  Coupon? coupon;


  Discountable({this.id = '', this.discountableType, this.discountableId,this.coupon,});

  factory Discountable.fromJSON(Map<String, dynamic>? jsonMap) {
    try {
      print('🎫 إنشاء Discountable من JSON: $jsonMap');
      
      Discountable discountable = Discountable(
        id: jsonMap?['id']?.toString() ?? '', 
        discountableType: jsonMap?['discountable_type']?.toString(), 
        discountableId: jsonMap?['discountable_id']?.toString(),
        coupon: jsonMap?['coupon'] != null ? Coupon.fromJSON(jsonMap!['coupon']) : null,
      );
      
      print('🎫 Discountable المنشأ:');
      print('🎫 - ID: ${discountable.id}');
      print('🎫 - Type: ${discountable.discountableType}');
      print('🎫 - DiscountableID: ${discountable.discountableId}');
      
      return discountable;
    } catch (e) {
      print('🎫 خطأ في إنشاء Discountable: $e');
      print(CustomTrace(StackTrace.current, message: e.toString()));
      return Discountable();
    }
  }

  Map<String, dynamic> toMap() {
    return {"id": id, "discountable_type": discountableType, "discountable_id": discountableId};
  }

  @override
  bool operator ==(Object other) => identical(this, other) || (other is Discountable && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
