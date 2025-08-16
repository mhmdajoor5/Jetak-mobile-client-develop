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
  // تم إزالة الضريبة لأن الأسعار تدخل مع الضريبة مسبقاً
  // double taxAmount = 0.0;
  double deliveryFee = 0.0;
  int cartCount = 0;
  double subTotal = 0.0;
  int estimatedTime = 0;
  double total = 0.0;
  bool isLoading = false;
  late GlobalKey<ScaffoldState> scaffoldKey;
  Coupon coupon = Coupon();
  int selectedTap = 1; // 1: Delivery, 2: Pickup

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

  void updateSelectedTap(int tap) {
    setState(() {
      selectedTap = tap;
    });
    calculateSubtotal();
  }

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
          content: Text(S.of(scaffoldKey.currentContext!).productRemovedFromCart),
        ),
      );
    } else {
      ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(
        SnackBar(
          content: Text(S.of(scaffoldKey.currentContext!).errorRemovingProduct),
        ),
      );
    }
  }

  void calculateSubtotal() {
    if (carts.isNotEmpty) {
      subTotal = 0;
      carts.forEach((cart) {
        // استخدام الدالة المحدثة في نموذج Cart
        double cartPrice = cart.getFoodPrice();
        cartPrice *= cart.quantity;
        subTotal += cartPrice;
      });

      // Restore delivery fee calculation
      bool canDeliver = Helper.canDelivery(carts[0].food!.restaurant, carts: carts);
      
      // رسوم التوصيل تعتمد على نوع الطلب
      // selectedTap == 1: Delivery, selectedTap == 2: Pickup
      if (selectedTap == 1) {
        // Delivery - استخدم رسوم التوصيل الأصلية دائماً
        deliveryFee = carts[0].food!.restaurant.deliveryFee;
      } else {
        // Pickup - لا توجد رسوم توصيل
        deliveryFee = 0.0;
      }
      
      print('🎫 نوع الطلب: ${selectedTap == 1 ? "Delivery" : "Pickup"}');
      print('🎫 يمكن التوصيل: $canDeliver');
      print('🎫 رسوم التوصيل الأصلية: ${carts[0].food!.restaurant.deliveryFee}');
      print('🎫 رسوم التوصيل المحسوبة: $deliveryFee');

      // تم إزالة الضريبة لأن الأسعار تدخل مع الضريبة مسبقاً
      // taxAmount = subTotal * carts[0].food!.restaurant.defaultTax / 100;
      
      // حساب الخصم من الكوبون
      double couponDiscount = 0.0;
      if (coupon.valid == true && coupon.discount != null && coupon.discountType != null) {
        if (coupon.discountType == 'fixed') {
          couponDiscount = coupon.discount!;
        } else if (coupon.discountType == 'percent') {
          couponDiscount = subTotal * (coupon.discount! / 100);
        }
        // التأكد من أن الخصم لا يتجاوز السعر الإجمالي
        if (couponDiscount > subTotal) {
          couponDiscount = subTotal;
        }
        
        print('🎫 حساب الخصم: $couponDiscount');
      }
      
      total = (subTotal - couponDiscount) + deliveryFee;
      print('🎫 السعر الفرعي: $subTotal');
      print('🎫 رسوم التوصيل: $deliveryFee');
      print('🎫 الخصم: $couponDiscount');
      print('🎫 السعر بعد الخصم: ${subTotal - couponDiscount}');
      print('🎫 السعر الإجمالي: $total');
      setState(() {});
    }
  }

  void doApplyCoupon(String code, {String? message}) async {
    print('🎫 بدء تطبيق الكوبون: $code');
    
    if (code.trim().isEmpty) {
      print('🎫 الكود فارغ');
      if (scaffoldKey.currentContext != null) {
        ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(
          SnackBar(
            content: Text('يرجى إدخال رمز الكوبون'),
          ),
        );
      }
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // جلب بيانات الكوبون من API
      print('🎫 جلب الكوبون من API...');
      Stream<Coupon> couponStream = await verifyCoupon(code);
      Coupon? foundCoupon;
      
      await for (Coupon couponData in couponStream) {
        foundCoupon = couponData;
        print('🎫 تم استلام كوبون من API:');
        print('🎫 - الكود: ${foundCoupon.code}');
        print('🎫 - الصحة: ${foundCoupon.valid}');
        print('🎫 - الخصم: ${foundCoupon.discount}');
        print('🎫 - نوع الخصم: ${foundCoupon.discountType}');
        print('🎫 - عدد القيود: ${foundCoupon.discountables?.length ?? 0}');
        break; // نأخذ أول كوبون فقط
      }

      if (foundCoupon == null) {
        print('🎫 لم يتم العثور على الكوبون');
        if (scaffoldKey.currentContext != null) {
          ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(
            SnackBar(
              content: Text('كوبون غير موجود'),
              backgroundColor: Colors.red,
            ),
          );
        }
        setState(() {
          isLoading = false;
        });
        return;
      }

      if (!foundCoupon.valid!) {
        print('🎫 الكوبون غير صالح');
        if (scaffoldKey.currentContext != null) {
          ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(
            SnackBar(
              content: Text('كوبون غير صالح'),
              backgroundColor: Colors.red,
            ),
          );
        }
        setState(() {
          isLoading = false;
        });
        return;
      }

      print('🎫 الكوبون صالح: ${foundCoupon.code}');
      print('🎫 نوع الخصم: ${foundCoupon.discountType}');
      print('🎫 قيمة الخصم: ${foundCoupon.discount}');

      // التحقق من أن الكوبون ينطبق على المطعم الحالي
      if (carts.isNotEmpty && foundCoupon.discountables != null && foundCoupon.discountables!.isNotEmpty) {
        String currentRestaurantId = carts[0].food!.restaurant.id.toString();
        bool isValidForRestaurant = foundCoupon.discountables!.any((discountable) =>
          discountable.discountableType == 'App\\Models\\Restaurant' &&
          discountable.discountableId.toString() == currentRestaurantId
        );

        if (!isValidForRestaurant) {
          print('🎫 الكوبون لا ينطبق على هذا المطعم');
          if (scaffoldKey.currentContext != null) {
            ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(
              SnackBar(
                content: Text('هذا الكوبون لا ينطبق على المطعم الحالي'),
                backgroundColor: Colors.orange,
              ),
            );
          }
          setState(() {
            isLoading = false;
          });
          return;
        }
      } else {
        print('🎫 الكوبون لا يحتوي على قيود مطاعم - سيتم تطبيقه');
      }

      // تطبيق الكوبون
      coupon = foundCoupon;
      
      // إعادة حساب السعر مع الخصم
      calculateSubtotal();
      
      print('🎫 الكوبون تم تطبيقه: ${coupon.code}');
      print('🎫 الخصم: ${coupon.discount}');
      print('🎫 نوع الخصم: ${coupon.discountType}');
      print('🎫 السعر الإجمالي الجديد: $total');
      
      // تحديث الـ UI
      setState(() {
        isLoading = false;
      });

      String discountText = '';
      if (coupon.discountType == 'fixed' && coupon.discount != null) {
        discountText = 'خصم ${coupon.discount} دينار';
      } else if (coupon.discountType == 'percent' && coupon.discount != null) {
        discountText = 'خصم ${coupon.discount}%';
      } else {
        discountText = 'خصم مطبق';
      }

      if (scaffoldKey.currentContext != null) {
        ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(
          SnackBar(
            content: Text('تم تطبيق الكوبون بنجاح! $discountText'),
            backgroundColor: Colors.green,
          ),
        );
      }

    } catch (e) {
      print('🎫 خطأ في تطبيق الكوبون: $e');
      if (scaffoldKey.currentContext != null) {
        ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ في تطبيق الكوبون'),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() {
        isLoading = false;
      });
    }
  }

  void removeCoupon() {
    coupon = Coupon();
    calculateSubtotal();
    setState(() {});
    if (scaffoldKey.currentContext != null) {
      ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(
        SnackBar(
          content: Text('تم إزالة الكوبون'),
          backgroundColor: Colors.blue,
        ),
      );
    }
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
