import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

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
  final LatLng restaurantLocation = LatLng(31.532640, 35.098614);
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

    if (latitude == null || longitude == null || restaurantId == null) {
      ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(
        SnackBar(content: Text('فشل في تحديد موقع التوصيل أو المطعم')),
      );
      return;
    }

    bool allowed = await checkDeliveryZone(
      restaurantId: restaurantId,
      latitude: latitude,
      longitude: longitude,
    );

    print('Allowed to deliver? $allowed');

    /// TODO : make it allowed only
    if (!allowed) {
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
    _order.deliveryFee =
        (payment?.method == 'Pay on Pickup')
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
          ).showSnackBar(SnackBar(content: Text('حدث خطأ أثناء إضافة الطلب')));
          setState(() {
            loading = false;
          });
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
}
