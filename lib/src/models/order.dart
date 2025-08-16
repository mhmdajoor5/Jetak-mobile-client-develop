import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:restaurantcustomer/src/models/restaurant.dart';

import '../helpers/custom_trace.dart';
import '../models/address.dart';
import '../models/coupon.dart';
import '../models/food_order.dart';
import '../models/order_status.dart';
import '../models/payment.dart';
import '../models/user.dart';
import 'food.dart';
import 'media.dart';

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
  Restaurant? restaurant;
  Coupon? coupon;

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
    this.restaurant,
    this.coupon,
  }) : orderStatus = orderStatus ?? OrderStatus.fromJSON({}),
       dateTime = dateTime ?? DateTime(0),
       user = user ?? User.fromJSON({}),
       payment = payment ?? Payment.fromJSON({}),
       deliveryAddress = deliveryAddress ?? Address.fromJSON({});

  factory Order.fromJSON(Map<String, dynamic>? jsonMap) {
    try {
      // طباعة البيانات المستلمة للتحقق
      print('🔍 تحليل بيانات الطلب:');
      print('   - id: ${jsonMap?['id']}');
      print('   - food_total: ${jsonMap?['food_total']}');
      print('   - tax: ${jsonMap?['tax']}');
      print('   - delivery_fee: ${jsonMap?['delivery_fee']}');
      print('   - food_orders: ${jsonMap?['food_orders']}');
      print('   - food_orders type: ${jsonMap?['food_orders']?.runtimeType}');
      print('   - food_orders length: ${jsonMap?['food_orders'] is List ? (jsonMap?['food_orders'] as List).length : 'N/A'}');
      
      List<FoodOrder> foodOrders = [];
      if (jsonMap?['food_orders'] != null && jsonMap!['food_orders'] is List && (jsonMap!['food_orders'] as List).isNotEmpty) {
        foodOrders = List<FoodOrder>.from(jsonMap!['food_orders'].map((e) => FoodOrder.fromJSON(e)));
        print('   - تم تحليل ${foodOrders.length} طعام');
      } else {
        print('   - ⚠️ food_orders فارغ أو غير موجود');
        // إنشاء FoodOrder افتراضي إذا كان food_total موجود
        if (jsonMap?['food_total'] != null) {
          double foodTotal = (jsonMap!['food_total'] as num).toDouble();
          print('   - إنشاء FoodOrder افتراضي بـ food_total: $foodTotal');
          foodOrders = [
            FoodOrder(
              id: '0',
              quantity: 1,
              price: foodTotal,
              extras: [],
              food: Food(
                id: '0',
                name: 'Food Items',
                price: foodTotal,
                description: 'Order items',
                image: Media(), // ensure non-null image with default placeholder
                category: null,
                restaurant: Restaurant(id: '0', name: ''),
              ),
            )
          ];
        }
      }
      
      // طباعة تأكيد البيانات المحللة
      print('   - عدد الأطعمة النهائي: ${foodOrders.length}');
      if (foodOrders.isNotEmpty) {
        print('   - سعر الطعام الأول: ${foodOrders.first.price}');
        print('   - اسم الطعام الأول: ${foodOrders.first.food?.name}');
      }
      
      // تحقق من بيانات العنوان المستلمة
      print('🔍 تحليل بيانات العنوان:');
      print('   - address raw: ${jsonMap?['delivery_address']}');
      if (jsonMap?['delivery_address'] != null) {
        var addressData = jsonMap!['delivery_address'];
        print('   - description: ${addressData['description']}');
        print('   - type: ${addressData['type']}');
        print('   - entryMethod: ${addressData['entry_method']}');
        print('   - instructions: ${addressData['instructions']}');
        print('   - label: ${addressData['label']}');
      }
      print('   - العنوان النهائي: ${jsonMap?['delivery_address'] != null ? Address.fromJSON(jsonMap!['delivery_address']).address : 'null'}');
      
      // تحقق من بيانات المستخدم
      print('👤 تحليل بيانات المستخدم:');
      print('   - user raw: ${jsonMap?['user']}');
      if (jsonMap?['user'] != null) {
        var userData = jsonMap!['user'];
        print('   - name: ${userData['name']}');
        print('   - email: ${userData['email']}');
        print('   - phone: ${userData['phone']}');
      }
      
      // 🏪 تحليل مصادر بيانات المطعم
      print('🏪 فحص مصادر بيانات المطعم:');
      print('   - restaurant raw: ${jsonMap?['restaurant']}');
      print('   - restaurant exists: ${jsonMap?['restaurant'] != null}');
      
      // فحص المصدر المباشر
      Restaurant? restaurantFromDirect = null;
      if (jsonMap?['restaurant'] != null) {
        var restaurantData = jsonMap!['restaurant'];
        print('   🎯 المصدر المباشر (restaurant):');
        print('     - keys: ${restaurantData.keys}');
        print('     - latitude: ${restaurantData['latitude']}');
        print('     - longitude: ${restaurantData['longitude']}');
        print('     - name: ${restaurantData['name']}');
        print('     - id: ${restaurantData['id']}');
        
        try {
          restaurantFromDirect = Restaurant.fromJSON(restaurantData);
          print('     ✅ تم تحليل restaurant مباشر بنجاح');
          print('     - parsed name: ${restaurantFromDirect.name}');
          print('     - parsed lat: ${restaurantFromDirect.latitude}');
          print('     - parsed lng: ${restaurantFromDirect.longitude}');
        } catch (e) {
          print('     ❌ خطأ في تحليل restaurant المباشر: $e');
        }
      } else {
        print('   ❌ المصدر المباشر: restaurant data not found');
      }
      
      // فحص المصدر البديل من food_orders
      Restaurant? restaurantFromFood = null;
      if (foodOrders.isNotEmpty && foodOrders[0].food?.restaurant != null) {
        restaurantFromFood = foodOrders[0].food!.restaurant;
        print('   🔄 المصدر البديل (food_orders[0].food.restaurant):');
        print('     - name: ${restaurantFromFood.name}');
        print('     - latitude: ${restaurantFromFood.latitude}');
        print('     - longitude: ${restaurantFromFood.longitude}');
        print('     - id: ${restaurantFromFood.id}');
      } else {
        print('   ❌ المصدر البديل: لا توجد بيانات مطعم في food_orders');
      }
      
      // اختيار أفضل مصدر للمطعم
      Restaurant? finalRestaurant = null;
      if (restaurantFromDirect != null && 
          restaurantFromDirect.latitude != '0' && 
          restaurantFromDirect.longitude != '0' &&
          restaurantFromDirect.latitude.isNotEmpty && 
          restaurantFromDirect.longitude.isNotEmpty) {
        finalRestaurant = restaurantFromDirect;
        print('   ✅ استخدام المصدر المباشر للمطعم');
      } else if (restaurantFromFood != null && 
                 restaurantFromFood.latitude != '0' && 
                 restaurantFromFood.longitude != '0' &&
                 restaurantFromFood.latitude.isNotEmpty && 
                 restaurantFromFood.longitude.isNotEmpty) {
        finalRestaurant = restaurantFromFood;
        print('   ✅ استخدام المصدر البديل للمطعم');
      } else {
        print('   ❌ لا توجد بيانات مطعم صحيحة في أي مصدر');
      }
      
      if (finalRestaurant != null) {
        print('   🎯 المطعم النهائي المختار:');
        print('     - name: ${finalRestaurant.name}');
        print('     - latitude: ${finalRestaurant.latitude}');
        print('     - longitude: ${finalRestaurant.longitude}');
      }
      
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
        restaurant: finalRestaurant, // استخدام أفضل مصدر للمطعم
        foodOrders: foodOrders,
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

    // إضافة الكوبون إذا كان موجوداً
    if (coupon != null && coupon!.valid == true && coupon!.code != null && coupon!.code!.isNotEmpty) {
      map["coupon_code"] = coupon!.code;
      print('🎫 إضافة كوبون للطلب: ${coupon!.code}');
    }

    // إرسال بيانات العنوان مباشرة بدلاً من ID فقط
    if (!deliveryAddress.isUnknown()) {
      map["delivery_address_id"] = deliveryAddress.id;
      // إرسال الإحداثيات مباشرة للباك إند
      map["latitude"] = deliveryAddress.latitude;
      map["longitude"] = deliveryAddress.longitude;
      
      // إرسال العنوان الأساسي فقط كـ string (بدون المعلومات الإضافية)
      map["address"] = deliveryAddress.address ?? '';
      
      // تجميع المعلومات الإضافية في حقل instructions
      List<String> additionalInfo = [];
      if (deliveryAddress.description?.isNotEmpty == true) {
        additionalInfo.add("Building: ${deliveryAddress.description}");
      }
      if (deliveryAddress.type?.isNotEmpty == true) {
        additionalInfo.add("Entrance: ${deliveryAddress.type}");
      }
      if (deliveryAddress.entryMethod?.isNotEmpty == true) {
        additionalInfo.add("Floor: ${deliveryAddress.entryMethod}");
      }
      if (deliveryAddress.instructions?.isNotEmpty == true) {
        additionalInfo.add("Unit: ${deliveryAddress.instructions}");
      }
      if (deliveryAddress.label?.isNotEmpty == true) {
        additionalInfo.add("Label: ${deliveryAddress.label}");
      }
      
      // إرسال المعلومات الإضافية كـ instructions
      if (additionalInfo.isNotEmpty) {
        map["instructions"] = additionalInfo.join(", ");
      }
      
      map["description"] = deliveryAddress.description;
      
      // طباعة تأكيد إرسال address كـ string
      print('🔍 تأكيد إرسال address في order.toMap():');
      print('   - نوع address: ${map["address"].runtimeType}');
      print('   - address value: ${map["address"]}');
      if (map["address"] is String) {
        print('   - ✅ address سيُرسل كـ string');
      } else {
        print('   - ❌ address لن يُرسل كـ string!');
      }
      
      // طباعة مفصلة للقيم الأصلية
      print('📍 تحليل بيانات العنوان:');
      print('   - address (الأساسي): ${deliveryAddress.address}');
      print('   - description (Building): ${deliveryAddress.description}');
      print('   - type (Entrance): ${deliveryAddress.type}');
      print('   - entryMethod (Floor): ${deliveryAddress.entryMethod}');
      print('   - instructions (Unit): ${deliveryAddress.instructions}');
      print('   - label: ${deliveryAddress.label}');
      print('📍 إرسال العنوان للباك إند:');
      print('   - address: ${map["address"]}');
      if (map.containsKey("instructions")) {
        print('   - instructions: ${map["instructions"]}');
      }
      print('📍 إرسال إحداثيات العنوان للباك إند: lat=${deliveryAddress.latitude}, lng=${deliveryAddress.longitude}');
    } else {
      print('⚠️ تحذير: العنوان لا يحتوي على إحداثيات صحيحة');
    }

    // طباعة نهائية للبيانات المرسلة
    print('📤 البيانات النهائية المرسلة من order.toMap():');
    map.forEach((key, value) {
      if (key == 'address') {
        print('   - $key: "$value" (نوع: ${value.runtimeType})');
      } else {
        print('   - $key: $value');
      }
    });
    
    return map;
  }

  Map<String, dynamic> cancelMap() {
    return {"id": id, if (orderStatus.id == '1') "active": false};
  }

  bool canCancelOrder() {
    return active && orderStatus.id == '1';
  }

  // دالة اختبار لطباعة العنوان كـ JSON
  void printAddressAsJSON() {
    print('ttt Order.printAddressAsJSON ');
    if (!deliveryAddress.isUnknown()) {
      Map<String, dynamic> addressObject = {
        "street": deliveryAddress.address ?? '',
        "city": "San Francisco",
        "country": "United States",
        "building": deliveryAddress.description ?? '',
        "floor": deliveryAddress.type ?? '',
        "apartment": deliveryAddress.entryMethod ?? '',
        "additional": deliveryAddress.instructions ?? '',
        "label": deliveryAddress.label ?? '',
      };
      
      print('🧪 اختبار العنوان كـ JSON:');
      print('   - address object: $addressObject');
      print('   - address JSON string: ${json.encode(addressObject)}');
    }
  }
}
