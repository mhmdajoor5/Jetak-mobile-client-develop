import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../helpers/helper.dart';
import '../models/cart.dart';
import '../models/coupon.dart';
import '../repository/cart_repository.dart';
import '../repository/coupon_repository.dart';

class CartController extends ControllerMVC {
  List<Cart> carts = <Cart>[];
  double taxAmount = 0.0;
  double deliveryFee = 0.0;
  int cartCount = 0;
  double subTotal = 0.0;
  int estimatedTime = 0;
  double total = 0.0;
  bool isLoading = false;
  late GlobalKey<ScaffoldState> scaffoldKey;
  Coupon coupon = Coupon();

  CartController() {
    scaffoldKey = GlobalKey<ScaffoldState>();
  }

  void listenForCarts({String? message}) async {
    carts.clear();
    final Stream<Cart> stream = await getCart();
    stream.listen(
      (Cart cart) {
        if (!carts.contains(cart)) {
          setState(() {
            coupon = cart.food!.applyCoupon(coupon);
            carts.add(cart);
          });
        }
      },
      onError: (e) {
        print(e);
        ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(
          SnackBar(
            content: Text(S.of(state!.context).verify_your_internet_connection),
          ),
        );
      },
      onDone: () {
        if (carts.isNotEmpty) {
          estimatedTime = carts
              .map((e) => e.food!.estTime)
              .reduce((a, b) => a > b ? a : b);
          calculateSubtotal();
        }
        if (message != null) {
          ScaffoldMessenger.of(
            scaffoldKey.currentContext!,
          ).showSnackBar(SnackBar(content: Text(message)));
        }
        onLoadingCartDone();
      },
    );
  }

  void onLoadingCartDone() {}

  void listenForCartsCount({String? message}) async {
    final Stream<int> stream = await getCartCount();
    stream.listen((int count) {
      setState(() {
        cartCount = count;
      });
    }, onError: (e) => print(e));
  }

  Future<void> refreshCarts() async {
    setState(() => carts = []);
    listenForCarts(message: S.of(state!.context).carts_refreshed_successfuly);
  }

  // void removeFromCart(Cart cart) async {
  //   setState(() => carts.remove(cart));
  //   await removeCart(cart);
  //   calculateSubtotal();
  //   ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(
  //     SnackBar(
  //       content: Text(
  //         S
  //             .of(state!.context)
  //             .the_food_was_removed_from_your_cart(cart.food!.name),
  //       ),
  //     ),
  //   );
  // }
  void removeFromCart(Cart cart) async {
    bool success = await removeCart(cart);
    if(success) {
      setState(() {
        carts.remove(cart);
      });
      ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(
        SnackBar(
          content: Text('تم حذف المنتج من السلة'),
        ),
      );
    } else {
      ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ أثناء حذف المنتج'),
        ),
      );
    }
  }

  void calculateSubtotal() {
    if (carts.isNotEmpty) {
      subTotal = 0;
      carts.forEach((cart) {
        double cartPrice = cart.food!.price;
        for (var extra in cart.extras) {
          cartPrice += extra.price;
        }
        cartPrice *= cart.quantity;
        subTotal += cartPrice;
      });

      // Restore delivery fee calculation
      deliveryFee =
          Helper.canDelivery(carts[0].food!.restaurant, carts: carts)
              ? carts[0].food!.restaurant.deliveryFee
              : 0;

      taxAmount = subTotal * carts[0].food!.restaurant.defaultTax / 100;
      total = subTotal + taxAmount + deliveryFee;
      setState(() {});
    }
  }

  void doApplyCoupon(String code, {String? message}) async {
    coupon = Coupon.fromJSON({"code": code, "valid": null});
    final Stream<Coupon> stream = await verifyCoupon(code);
    stream.listen(
      (Coupon c) {
        coupon = c;
      },
      onError: (e) {
        print(e);
        ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(
          SnackBar(
            content: Text(S.of(state!.context).verify_your_internet_connection),
          ),
        );
      },
      onDone: () => listenForCarts(),
    );
  }

  void incrementQuantity(Cart cart) {
    if (cart.quantity < 100) {
      cart.quantity++;
      updateCart(cart);
      calculateSubtotal();
    }
  }

  void decrementQuantity(Cart cart) {
    if (cart.quantity > 1) {
      cart.quantity--;
      updateCart(cart);
      calculateSubtotal();
    }
  }

  /// TODO : here !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  /// mElkerm : i made this change to be able to complete the order
  void goCheckout(BuildContext context) {
    print("mElkerm : HEREEEEEE");
    // if (!currentUser.value.profileCompleted()) {
    //   ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(
    //     SnackBar(
    //       content: Text(S.of(context).completeYourProfileDetailsToContinue),
    //       action: SnackBarAction(
    //         label: S.of(context).settings,
    //         textColor: Theme.of(context).colorScheme.secondary,
    //         onPressed: () {
    //           Navigator.of(context).pushNamed('/Settings');
    //         },
    //       ),
    //     ),
    //   );
    // } else {
    if (carts[0].food!.restaurant.closed) {
      ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(
        SnackBar(content: Text(S.of(context).this_restaurant_is_closed_)),
      );
    } else {
      Navigator.of(context).pushNamed('/DeliveryPickup');
    }
    // }
  }

  Color getCouponIconColor() {
    if (coupon.valid == true) {
      return Colors.green;
    } else if (coupon.valid == false) {
      return Colors.redAccent;
    }
    return Theme.of(state!.context).focusColor.withOpacity(0.7);
  }
}
