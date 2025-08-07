import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:restaurantcustomer/src/models/address.dart';

import '../../generated/l10n.dart';
import '../models/cart.dart';
import '../models/coupon.dart';
import '../models/credit_card.dart';
import '../models/food_order.dart';
import '../models/order.dart';
import '../models/order_status.dart';
import '../models/payment.dart';
import '../models/route_argument.dart';
import '../repository/order_repository.dart' as orderRepo;
import '../repository/settings_repository.dart' as settingRepo;
import '../repository/user_repository.dart' as userRepo;
import 'cart_controller.dart';

class CheckoutController extends CartController {
  Payment? payment;
  CreditCard creditCard = CreditCard();
  bool loading = true;
  // ❌ الموقع الافتراضي الثابت محذوف - سيتم الحصول على موقع المطعم ديناميكياً
  LatLng? restaurantLocation; // ← سيتم تحديده من بيانات المطعم الحقيقية
  final LatLng clientLocation = LatLng(31.536833, 35.050363);

  CheckoutController() {
    this.scaffoldKey = GlobalKey<ScaffoldState>();
    listenForCreditCard();
  }

  void listenForCreditCard() async {
    creditCard = await userRepo.getCreditCard();
    setState(() {});
  }

  @override
  void onLoadingCartDone() {
    if (payment != null) {
      checkAndAddOrder(carts);
    }
  }

  void checkAndAddOrder(List<Cart> carts) async {
    print('▶️ تم استدعاء checkAndAddOrder');
    final double? latitude = settingRepo.deliveryAddress.value?.latitude;
    final double? longitude = settingRepo.deliveryAddress.value?.longitude;

    int? restaurantId;
    if (carts.isNotEmpty && carts[0].food?.restaurant.id != null) {
      restaurantId = int.tryParse(carts[0].food!.restaurant.id.toString());
    }

    // التحقق من وجود العنوان والإحداثيات
    if (settingRepo.deliveryAddress.value == null) {
      ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(
        SnackBar(content: Text('يرجى اختيار عنوان التوصيل أولاً')),
      );
      return;
    }

    if (latitude == null || longitude == null) {
      print('❌ العنوان لا يحتوي على إحداثيات صحيحة: lat=$latitude, lng=$longitude');
      ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(
        SnackBar(content: Text('العنوان المحدد لا يحتوي على إحداثيات صحيحة. يرجى إعادة تحديد العنوان')),
      );
      return;
    }

    if (restaurantId == null) {
      ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(
        SnackBar(content: Text('فشل في تحديد المطعم')),
      );
      return;
    }

    print('📍 التحقق من نطاق التوصيل: المطعم $restaurantId، الإحداثيات ($latitude, $longitude)');

    bool allowed = await checkDeliveryZone(
      restaurantId: restaurantId,
      latitude: latitude,
      longitude: longitude,
    );

    print('✅ هل يسمح بالتوصيل؟ $allowed');

    if (allowed) {
      addOrder(carts);
    } else {
      ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(
        SnackBar(content: Text('العنوان خارج نطاق التوصيل الخاص بالمطعم')),
      );
      setState(() {
        loading = false;
      });
    }
  }

  Future<bool> checkDeliveryZone({
    required int restaurantId,
    required double latitude,
    required double longitude,
  }) async {
    print('➡️  $restaurantId على الإحداثيات ($latitude, $longitude)');
    final url = Uri.parse('https://carrytechnologies.co/api/check-delivery');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "restaurant_id": restaurantId,
          "latitude": latitude,
          "longitude": longitude,
        }),
      );
      print('⬅️ ${response.statusCode} – ${response.body}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final bool allowed = data['is_delivery'] == true;
        print('✅ Parsed is_delivery = $allowed');
        return allowed;
      } else {
        print('❌ HTTP error ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('⚠️ خطأ في التحقق من التوصيل: $e');
      return false;
    }
  }

  void addOrder(List<Cart> carts) {
    if (payment == null) {
      print('❌ payment is null');
      ScaffoldMessenger.of(
        scaffoldKey.currentContext!,
      ).showSnackBar(SnackBar(content: Text('خطأ في طريقة الدفع')));
      return;
    }

    Order _order = Order();
    _order.foodOrders = <FoodOrder>[];
    _order.tax = carts[0].food?.restaurant.defaultTax ?? 0.0;
    
    // تحديد نوع الطلب بناءً على طريقة الدفع
    String orderType = 'delivery'; // القيمة الافتراضية
    if (payment?.method == 'Pay on Pickup') {
      // Cash on Pickup disabled - only Pay on Pickup allowed
      orderType = 'pickup';
    }
    
    _order.orderType = orderType;
    print('📦 نوع الطلب: $orderType');
    
    _order.deliveryFee =
        (orderType == 'pickup')
            ? 0
            : carts[0].food?.restaurant.deliveryFee ?? 0;
    OrderStatus _orderStatus = OrderStatus()..id = '1';
    _order.orderStatus = _orderStatus;
    _order.deliveryAddress = settingRepo.deliveryAddress.value;

    for (var _cart in carts) {
      FoodOrder _foodOrder =
          FoodOrder()
            ..quantity = _cart.quantity
            ..price = _cart.food?.price ?? 0.0
            ..food = _cart.food
            ..extras = _cart.extras;
      _order.foodOrders.add(_foodOrder);
    }

    print('📦 جاري إضافة الطلب...');
    print('📦 طريقة الدفع: ${payment?.method}');
    
    // التحقق النهائي من وجود الإحداثيات قبل الإرسال
    if (_order.deliveryAddress.latitude == null || _order.deliveryAddress.longitude == null) {
      print('❌ خطأ: العنوان لا يحتوي على إحداثيات صحيحة قبل الإرسال');
      ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(
        SnackBar(content: Text('خطأ في بيانات العنوان. يرجى إعادة تحديد العنوان')),
      );
      setState(() {
        loading = false;
      });
      return;
    }
    
    print('📍 تأكيد الإحداثيات قبل الإرسال: lat=${_order.deliveryAddress.latitude}, lng=${_order.deliveryAddress.longitude}');
    
    // اختبار طباعة العنوان كـ JSON
    _order.printAddressAsJSON();
    
    // تجميع العنوان للطباعة
    print('📍 العنوان المرسل:');
    print('   - address: ${_order.deliveryAddress.address}');
    print('   - description (Building): ${_order.deliveryAddress.description}');
    print('   - type (Entrance): ${_order.deliveryAddress.type}');
    print('   - entryMethod (Floor): ${_order.deliveryAddress.entryMethod}');
    print('   - instructions (Unit): ${_order.deliveryAddress.instructions}');
    print('   - label: ${_order.deliveryAddress.label}');
    print('   - latitude: ${_order.deliveryAddress.latitude}');
    print('   - longitude: ${_order.deliveryAddress.longitude}');

    orderRepo
        .addOrder(_order, payment!)
        .then((value) async {
          print('📦 ✅ Response من السيرفر بعد تنفيذ الطلب: $value');
          settingRepo.coupon = Coupon.fromJSON({});
          return value;
        })
        .then((value) {
          setState(() {
            loading = false;
          });
          // Navigator.of(scaffoldKey.currentContext!).pushNamed(
          //   '/OrderSuccess',
          //   arguments: RouteArgument(param: payment?.method ?? 'Unknown'),
          // );
        })
        .catchError((error) {
          print('❌ خطأ في إضافة الطلب: $error');
          ScaffoldMessenger.of(
            scaffoldKey.currentContext!,
          );
        });
  }

  void updateCreditCard(CreditCard creditCard) {
    userRepo.setCreditCard(creditCard).then((_) {
      setState(() {});
      ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(
        SnackBar(
          content: Text(S.of(state!.context).payment_card_updated_successfully),
        ),
      );
    });
  }

  // دالة منفصلة لإرسال بيانات العنوان للباك إند
  Map<String, dynamic> getDeliveryAddressData() {
    Address address = settingRepo.deliveryAddress.value;
    
    if (address.isUnknown()) {
      print('⚠️ تحذير: العنوان لا يحتوي على إحداثيات صحيحة');
      return {};
    }
    
    // تجميع المعلومات الإضافية في حقل instructions
    List<String> additionalInfo = [];
    if (address.description?.isNotEmpty == true) {
      additionalInfo.add("Building: ${address.description}");
    }
    if (address.type?.isNotEmpty == true) {
      additionalInfo.add("Entrance: ${address.type}");
    }
    if (address.entryMethod?.isNotEmpty == true) {
      additionalInfo.add("Floor: ${address.entryMethod}");
    }
    if (address.instructions?.isNotEmpty == true) {
      additionalInfo.add("Unit: ${address.instructions}");
    }
    if (address.label?.isNotEmpty == true) {
      additionalInfo.add("Label: ${address.label}");
    }
    
    Map<String, dynamic> addressData = {
      "delivery_address_id": address.id,
      "address": address.address ?? '',
      "latitude": address.latitude,
      "longitude": address.longitude,
    };
    
    // إضافة instructions إذا كانت هناك معلومات إضافية
    if (additionalInfo.isNotEmpty) {
      addressData["instructions"] = additionalInfo.join(", ");
    }
    
    print('📍 إرسال بيانات العنوان للباك إند:');
    print('   - address: ${address.address}');
    print('   - description (Building): ${address.description}');
    print('   - type (Entrance): ${address.type}');
    print('   - entryMethod (Floor): ${address.entryMethod}');
    print('   - instructions (Unit): ${address.instructions}');
    print('   - label: ${address.label}');
    if (additionalInfo.isNotEmpty) {
      print('   - instructions: ${additionalInfo.join(", ")}');
    }
    print('   - latitude: ${address.latitude}');
    print('   - longitude: ${address.longitude}');
    
    return addressData;
  }
}
