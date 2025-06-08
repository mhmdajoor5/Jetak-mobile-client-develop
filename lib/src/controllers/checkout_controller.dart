import 'dart:math';
import 'package:flutter/material.dart';
import '../../generated/l10n.dart';
import '../models/cart.dart';
import '../models/coupon.dart';
import '../models/credit_card.dart';
import '../models/food_order.dart';
import '../models/order.dart';
import '../models/order_status.dart';
import '../models/payment.dart';
import '../repository/order_repository.dart' as orderRepo;
import '../repository/settings_repository.dart' as settingRepo;
import '../repository/user_repository.dart' as userRepo;
import 'cart_controller.dart';

class CheckoutController extends CartController {
  Payment? payment;
  CreditCard creditCard = CreditCard();
  bool loading = true;
  bool isWithinDeliveryRange = true;

  CheckoutController() {
    scaffoldKey = GlobalKey<ScaffoldState>();
    listenForCreditCard();
  }

  void listenForCreditCard() async {
    creditCard = await userRepo.getCreditCard();
    setState(() {});
  }

  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) *
            (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  @override
  void onLoadingCartDone() {
    if (payment != null) addOrder(carts);
    super.onLoadingCartDone();
  }

  void addOrder(List<Cart> carts) async {
    final userLat = (settingRepo.deliveryAddress.value.latitude as num?)?.toDouble() ?? 0.0;
    final userLng = (settingRepo.deliveryAddress.value.longitude as num?)?.toDouble() ?? 0.0;
    final restLat = (carts[0].food?.restaurant.latitude as num?)?.toDouble() ?? 0.0;
    final restLng = (carts[0].food?.restaurant.longitude as num?)?.toDouble() ?? 0.0;

    final distance = calculateDistance(userLat, userLng, restLat, restLng);
    final deliveryRadius = carts[0].food?.restaurant.deliveryRange ?? 0;
    isWithinDeliveryRange = distance <= deliveryRadius;

    if (!isWithinDeliveryRange) {
      ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(
        SnackBar(content: Text(S.of(state!.context).deliveryAddressOutsideRange)),
      );
      setState(() => loading = false);
      return;
    }

    Order _order = Order();
    _order.foodOrders = [];
    _order.tax = carts[0].food?.restaurant.defaultTax?.toDouble() ?? 0;
    _order.deliveryFee = payment!.method == 'Pay on Pickup'
        ? 0
        : carts[0].food?.restaurant.deliveryFee ?? 0;

    var status = OrderStatus()..id = '1';
    _order.orderStatus = status;
    _order.deliveryAddress = settingRepo.deliveryAddress.value;

    for (var cart in carts) {
      var fo = FoodOrder()
        ..quantity = cart.quantity
        ..price = cart.food?.price?.toDouble() ?? 0
        ..food = cart.food
        ..extras = cart.extras;
      _order.foodOrders!.add(fo);
    }

    orderRepo.addOrder(_order, payment!).then((_) {
      settingRepo.coupon = Coupon.fromJSON({});
    }).whenComplete(() {
      setState(() => loading = false);
    });
  }

  void updateCreditCard(CreditCard card) {
    userRepo.setCreditCard(card).then((_) {
      setState(() {});
      ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(
        SnackBar(content: Text(S.of(state!.context).payment_card_updated_successfully)),
      );
    });
  }
}
