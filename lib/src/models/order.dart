import '../helpers/custom_trace.dart';
import '../models/address.dart';
import '../models/food_order.dart';
import '../models/order_status.dart';
import '../models/payment.dart';
import '../models/user.dart';

class Order {
  String id;
  List<FoodOrder> foodOrders;
  OrderStatus orderStatus;
  double tax;
  double deliveryFee;
  String hint;
  bool active;
  DateTime dateTime;
  User user;
  Payment payment;
  Address deliveryAddress;
  String orderType;

  Order({
    this.id = '',
    this.foodOrders = const [],
    OrderStatus? orderStatus,
    this.tax = 0.0,
    this.deliveryFee = 0.0,
    this.hint = '',
    this.active = false,
    this.orderType = 'delivery',
    DateTime? dateTime,
    User? user,
    Payment? payment,
    Address? deliveryAddress,
  }) : orderStatus = orderStatus ?? OrderStatus.fromJSON({}),
       dateTime = dateTime ?? DateTime(0),
       user = user ?? User.fromJSON({}),
       payment = payment ?? Payment.fromJSON({}),
       deliveryAddress = deliveryAddress ?? Address.fromJSON({});

  factory Order.fromJSON(Map<String, dynamic>? jsonMap) {
    try {
      return Order(
        id: jsonMap?['id']?.toString() ?? '',
        tax: (jsonMap?['tax'] as num?)?.toDouble() ?? 0.0,
        deliveryFee: (jsonMap?['delivery_fee'] as num?)?.toDouble() ?? 0.0,
        hint: jsonMap?['hint']?.toString() ?? '',
        active: jsonMap?['active'] ?? false,
        orderStatus: jsonMap?['order_status'] != null ? OrderStatus.fromJSON(jsonMap!['order_status']) : OrderStatus.fromJSON({}),
        dateTime: jsonMap?['updated_at'] != null ? DateTime.tryParse(jsonMap!['updated_at']) ?? DateTime(0) : DateTime(0),
        user: jsonMap?['user'] != null ? User.fromJSON(jsonMap!['user']) : User.fromJSON({}),
        deliveryAddress: jsonMap?['delivery_address'] != null ? Address.fromJSON(jsonMap!['delivery_address']) : Address.fromJSON({}),
        payment: jsonMap?['payment'] != null ? Payment.fromJSON(jsonMap!['payment']) : Payment.fromJSON({}),
        foodOrders: jsonMap?['food_orders'] != null ? List<FoodOrder>.from(jsonMap!['food_orders'].map((e) => FoodOrder.fromJSON(e))) : [],
      );
    } catch (e) {
      print(CustomTrace(StackTrace.current, message: e.toString()));
      return Order();
    }
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      "id": id,
      "user_id": user.id,
      "order_status_id": orderStatus.id,
      "tax": tax,
      "hint": hint,
      "delivery_fee": deliveryFee,
      "foods": foodOrders.map((e) => e.toMap()).toList(),
      "payment": payment.toMap(),
      "order_type": orderType,
    };

    // إرسال بيانات العنوان مباشرة بدلاً من ID فقط
    if (!deliveryAddress.isUnknown()) {
      map["delivery_address_id"] = deliveryAddress.id;
      // إرسال الإحداثيات مباشرة للباك إند
      map["latitude"] = deliveryAddress.latitude;
      map["longitude"] = deliveryAddress.longitude;
      map["address"] = deliveryAddress.address;
      map["description"] = deliveryAddress.description;
      print('📍 إرسال إحداثيات العنوان للباك إند: lat=${deliveryAddress.latitude}, lng=${deliveryAddress.longitude}');
    } else {
      print('⚠️ تحذير: العنوان لا يحتوي على إحداثيات صحيحة');
    }

    return map;
  }

  Map<String, dynamic> cancelMap() {
    return {"id": id, if (orderStatus.id == '1') "active": false};
  }

  bool canCancelOrder() {
    return active && orderStatus.id == '1';
  }
}
