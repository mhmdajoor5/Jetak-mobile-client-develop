import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'dart:convert';
import '../../generated/l10n.dart';
import '../controllers/delivery_pickup_controller.dart';
import '../elements/CartBottomDetailsWidget.dart';
import '../elements/back_button.dart';
import '../elements/order_summary.dart';
import '../elements/tip_item.dart';
import '../elements/custom_material_button.dart';
import '../elements/custom_tab_bar.dart';
import '../elements/custom_text_field.dart';
import '../elements/payment_method_card.dart';
import '../helpers/app_colors.dart';
import '../helpers/app_text_styles.dart';
import '../helpers/helper.dart';
import '../helpers/swipe_button_widget.dart';
import '../helpers/icredit_validator.dart';
import '../models/address.dart';
import '../models/icredit_charge_simple_reesponse.dart';
import '../models/icredit_create_sale_response.dart' show ICreditCreateSaleResponse;
import '../models/payment_method.dart';
import '../models/route_argument.dart';
import '../repository/settings_repository.dart';
import 'order_success.dart';
import '../models/card_item.dart';
import '../models/icredit_create_sale_body.dart';
import '../repository/icredit_repository.dart';
import '../models/order.dart';
import '../models/food_order.dart';
import '../models/order_status.dart';
import '../models/payment.dart';

class DeliveryPickupWidget extends StatefulWidget {
  final RouteArgument? routeArgument;

  const DeliveryPickupWidget({super.key, this.routeArgument});

  @override
  _DeliveryPickupWidgetState createState() => _DeliveryPickupWidgetState();
}

int selectedTap = 1;
String selectedPaymentMethod = '';
double? _tipValue = 0;
bool showCards = false;

class _DeliveryPickupWidgetState extends StateMVC<DeliveryPickupWidget> {
  late DeliveryPickupController _con;

  List<CardItem> savedCards = [];
  int selectedCardIndex = -1;
  late TextEditingController addressController;
  TextEditingController couponController = TextEditingController();

  _DeliveryPickupWidgetState() : super(DeliveryPickupController()) {
    _con = controller as DeliveryPickupController;
  }

  String _tr(BuildContext context, {required String en, required String ar, required String he}) {
    final code = Localizations.localeOf(context).languageCode;
    if (code == 'ar') return ar;
    if (code == 'he') return he;
    return en;
  }

  @override
  void initState() {
    super.initState();

    addressController = TextEditingController(text: '');

    if (widget.routeArgument?.param != null && widget.routeArgument!.param is Address) {
      Address selectedAddress = widget.routeArgument!.param as Address;
      _con.deliveryAddress = selectedAddress;
      _con.userDeliverAddress = selectedAddress.address ?? '';
      addressController.text = _con.userDeliverAddress; // عرض العنوان الكامل
      print('[DEBUG] تم تعيين العنوان من routeArgument: ${selectedAddress.address}');
    } else {
      print('[DEBUG] لم يتم تمرير عنوان من routeArgument');
    }

    _loadSavedCards();
  }

  @override
  void dispose() {
    addressController.dispose();
    couponController.dispose();
    super.dispose();
  }

  // Future<void> _sendOrder() async {
  //   String orderType = selectedTap == 1 ? 'delivery' : 'pickup';
  //
  //   Map<String, dynamic> orderData = {
  //     "items": _con.carts.map((item) => item.toJson()).toList(),
  //     "total": _con.total,
  //     "orderType": orderType,
  //     "address": selectedTap == 1 ? _con.deliveryAddress?.toJson() : null,
  //     "paymentMethod": selectedPaymentMethod,
  //   };
  //
  //   try {
  //     await FirebaseFirestore.instance.collection('orders').add(orderData);
  //     print('[DEBUG] تم إرسال الطلب إلى Firestore بنجاح');
  //   } catch (e) {
  //     print('[DEBUG] خطأ في إرسال الطلب: $e');
  //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //       content: Text("❌ فشل في إرسال الطلب. حاول مرة أخرى."),
  //       backgroundColor: Colors.red,
  //     ));
  //   }
  // }

  Future<void> _loadSavedCards() async {
    savedCards = await Helper.getSavedCards();
    setState(() {});
  }

  double returnTheTotal(){
    if (selectedTap == 2) {
      return _con.total - _con.deliveryFee;
    }
    return _con.total;
  }

  // دالة لإنشاء الطلب في النظام
  Future<void> _createOrderInSystem(String orderType) async {
    try {
      print('[DEBUG] إنشاء الطلب في النظام مع orderType: $orderType');

      // تحقق من وجود عناصر في السلة
      if (_con.carts.isEmpty) {
        print('[DEBUG] ❌ لا يمكن إنشاء طلب بدون عناصر في السلة');
        return;
      }

      // تحقق من صحة بيانات المطعم
      if (_con.carts[0].food?.restaurant == null) {
        print('[DEBUG] ❌ بيانات المطعم غير صحيحة');
        return;
      }

      // إنشاء كائن Order
      Order order = Order();
      order.foodOrders = <FoodOrder>[];
      order.tax = _con.carts[0].food?.restaurant.defaultTax ?? 0.0;
      order.orderType = orderType; // تحديد نوع الطلب
      order.deliveryFee = orderType == 'pickup' ? 0 : (_con.carts[0].food?.restaurant.deliveryFee ?? 0);

      // إنشاء OrderStatus
      OrderStatus orderStatus = OrderStatus()..id = '1';
      order.orderStatus = orderStatus;

      // إضافة عنوان التوصيل إذا كان للتوصيل
      if (selectedTap == 1 && _con.deliveryAddress != null) {
        // تحقق إضافي من صحة العنوان قبل إضافته
        if (_con.deliveryAddress!.address != null && 
            _con.deliveryAddress!.address!.trim().isNotEmpty &&
            _con.deliveryAddress!.latitude != null &&
            _con.deliveryAddress!.longitude != null &&
            _con.deliveryAddress!.description != null &&
            _con.deliveryAddress!.description!.trim().isNotEmpty) {
          order.deliveryAddress = _con.deliveryAddress!;
        } else {
          print('[DEBUG] ❌ العنوان لا يحتوي على بيانات صحيحة كاملة');
          return;
        }
      }

      // إضافة الأطعمة
      for (var cart in _con.carts) {
        FoodOrder foodOrder = FoodOrder()
          ..quantity = cart.quantity
          ..price = cart.food?.price ?? 0.0
          ..food = cart.food
          ..extras = cart.extras;
        order.foodOrders.add(foodOrder);
      }

      // إنشاء Payment
      Payment payment = Payment();
      if (selectedPaymentMethod == 'credit') {
        payment.method = selectedTap == 1 ? 'iCredit Delivery' : 'iCredit Pickup';
      } 
      // Cash payment disabled
      // else if (selectedPaymentMethod == 'cash') {
      //   payment.method = selectedTap == 1 ? 'Cash on Delivery' : 'Cash on Pickup';
      // }
      order.payment = payment;

      print('[DEBUG] بيانات الطلب:');
      print('- orderType: ${order.orderType}');
      print('- deliveryFee: ${order.deliveryFee}');
      print('- payment.method: ${order.payment.method}');

      // إرسال الطلب إلى النظام
      // هنا يمكنك إضافة الكود لإرسال الطلب إلى API الخاص بك

    } catch (e) {
      print('[DEBUG] ❌ خطأ في إنشاء الطلب في النظام: $e');
    }
  }

  Future<void> completeSale() async {
    print('--- [DEBUG] بدء عملية الطلب ---');
    
    // تحقق من وجود عناصر في السلة
    if (_con.carts.isEmpty) {
      print('[DEBUG] السلة فارغة!');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_tr(context, en: 'The cart is empty, please add products first', ar: 'السلة فارغة، يرجى إضافة منتجات أولاً', he: 'העגלה ריקה, נא להוסיף מוצרים תחילה')),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    // تحقق شامل من العنوان للتوصيل
    if (selectedTap == 1) {
      print('[DEBUG] التحقق من العنوان للتوصيل...');
      print('[DEBUG] _con.deliveryAddress: ${_con.deliveryAddress}');
      print('[DEBUG] addressController.text: "${addressController.text}"');
      print('[DEBUG] _con.userDeliverAddress: "${_con.userDeliverAddress}"');
      
      // تحقق من وجود العنوان في الكنترولر
      if (_con.deliveryAddress == null) {
        print('[DEBUG] لم يتم اختيار عنوان!');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ الرجاء اختيار عنوان التوصيل'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // تحقق من أن العنوان يحتوي على بيانات صحيحة
      if (_con.deliveryAddress?.address == null || 
          _con.deliveryAddress!.address!.trim().isEmpty) {
        print('[DEBUG] العنوان فارغ أو غير صحيح!');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ العنوان المحدد غير صحيح، يرجى اختيار عنوان آخر'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // تحقق إضافي من نص العنوان في الكنترولر
      if (addressController.text.trim().isEmpty) {
        print('[DEBUG] نص العنوان في الكنترولر فارغ!');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_tr(context, en: 'Please select a delivery address from the list', ar: 'يرجى اختيار عنوان التوصيل من القائمة', he: 'נא לבחור כתובת משלוח מהרשימה')),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // تحقق من أن العنوان لا يحتوي على نص افتراضي
      if (addressController.text.trim() == S.of(context).address) {
        print('[DEBUG] العنوان يحتوي على نص افتراضي!');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_tr(context, en: 'Please select a delivery address from the list', ar: 'يرجى اختيار عنوان التوصيل من القائمة', he: 'נא לבחור כתובת משלוח מהרשימה')),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // تحقق من أن العنوان تم اختياره من القائمة وليس مجرد نص مكتوب
      if (_con.deliveryAddress == null || 
          _con.deliveryAddress!.address != addressController.text.trim()) {
        print('[DEBUG] العنوان لم يتم اختياره من القائمة!');
        print('[DEBUG] _con.deliveryAddress?.address: ${_con.deliveryAddress?.address}');
        print('[DEBUG] addressController.text.trim(): ${addressController.text.trim()}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_tr(context, en: 'Please select a delivery address from the list', ar: 'يرجى اختيار عنوان التوصيل من القائمة', he: 'נא לבחור כתובת משלוח מהרשימה')),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // تحقق من وجود الإحداثيات
      if (_con.deliveryAddress?.latitude == null || 
          _con.deliveryAddress?.longitude == null) {
        print('[DEBUG] العنوان لا يحتوي على إحداثيات صحيحة!');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ العنوان لا يحتوي على موقع صحيح، يرجى اختيار عنوان آخر'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // تحقق من وجود وصف العنوان
      if (_con.deliveryAddress?.description == null || 
          _con.deliveryAddress!.description!.trim().isEmpty) {
        print('[DEBUG] العنوان لا يحتوي على وصف صحيح!');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ العنوان لا يحتوي على وصف صحيح، يرجى اختيار عنوان آخر'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      print('[DEBUG] ✅ تم التحقق من العنوان بنجاح');

      final canDeliver = await _con.checkDeliveryArea();
      print('[DEBUG] نتيجة checkDeliveryArea: $canDeliver');
      if (!canDeliver) {
        print('[DEBUG] العنوان خارج نطاق التوصيل!');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('عذراً، عنوانك خارج منطقة التوصيل المتاحة'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
          ),
        );
        return;
      }
    }

    // تحقق من اختيار طريقة الدفع
    if (selectedPaymentMethod.isEmpty) {
      print('[DEBUG] لم يتم اختيار طريقة دفع!');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ يرجى اختيار طريقة دفع'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    print('[DEBUG] بعد التحقق من التوصيل، أكمل باقي خطوات الطلب');
    // استدعاء دالة الفالديشن والدفع الجديدة
    await _proceedWithPayment();
  }

  Future<void> _proceedWithPayment() async {
    print('[DEBUG] بدء عملية الدفع - طريقة الدفع: $selectedPaymentMethod');

    // تحقق من وجود عناصر في السلة
    if (_con.carts.isEmpty) {
      print('[DEBUG] السلة فارغة في _proceedWithPayment!');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ السلة فارغة، يرجى إضافة منتجات أولاً'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // تحقق شامل من العنوان إذا كان الطلب توصيل
    if (selectedTap == 1) {
      print('[DEBUG] التحقق من العنوان في _proceedWithPayment...');
      print('[DEBUG] _con.deliveryAddress: ${_con.deliveryAddress}');
      print('[DEBUG] addressController.text: "${addressController.text}"');
      
      if (_con.deliveryAddress == null) {
        print('[DEBUG] لم يتم اختيار عنوان في _proceedWithPayment!');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ يرجى اختيار عنوان التوصيل أولاً'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (_con.deliveryAddress?.address == null || 
          _con.deliveryAddress!.address!.trim().isEmpty) {
        print('[DEBUG] العنوان فارغ في _proceedWithPayment!');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ العنوان المحدد غير صحيح، يرجى اختيار عنوان آخر'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // تحقق إضافي من نص العنوان في الكنترولر
      if (addressController.text.trim().isEmpty) {
        print('[DEBUG] نص العنوان في الكنترولر فارغ في _proceedWithPayment!');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ يرجى اختيار عنوان التوصيل من القائمة'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // تحقق من أن العنوان لا يحتوي على نص افتراضي
      if (addressController.text.trim() == S.of(context).address) {
        print('[DEBUG] العنوان يحتوي على نص افتراضي في _proceedWithPayment!');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ يرجى اختيار عنوان التوصيل من القائمة'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // تحقق من أن العنوان تم اختياره من القائمة وليس مجرد نص مكتوب
      if (_con.deliveryAddress == null || 
          _con.deliveryAddress!.address != addressController.text.trim()) {
        print('[DEBUG] العنوان لم يتم اختياره من القائمة في _proceedWithPayment!');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ يرجى اختيار عنوان التوصيل من القائمة'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (_con.deliveryAddress?.latitude == null || 
          _con.deliveryAddress?.longitude == null) {
        print('[DEBUG] العنوان لا يحتوي على إحداثيات في _proceedWithPayment!');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ العنوان لا يحتوي على موقع صحيح، يرجى اختيار عنوان آخر'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (_con.deliveryAddress?.description == null || 
          _con.deliveryAddress!.description!.trim().isEmpty) {
        print('[DEBUG] العنوان لا يحتوي على وصف في _proceedWithPayment!');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ العنوان لا يحتوي على وصف صحيح، يرجى اختيار عنوان آخر'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      print('[DEBUG] ✅ تم التحقق من العنوان في _proceedWithPayment بنجاح');
    }

    // تحقق من اختيار طريقة الدفع
    if (selectedPaymentMethod.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ يرجى اختيار طريقة دفع'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // فالديشن طريقة الدفع بالبطاقة الائتمانية
    if (selectedPaymentMethod == 'credit') {
      String orderType = selectedTap == 1 ? 'delivery' : 'pickup';
      print('Order type is: $orderType');

      print('[DEBUG] تم اختيار الدفع بالبطاقة');

      // التحقق من اختيار بطاقة
      if (selectedCardIndex == -1) {
        print('[DEBUG] ❌ لم يتم اختيار أي بطاقة!');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("❌ يرجى اختيار بطاقة للدفع"),
          backgroundColor: Colors.red,
        ));
        return;
      }

      // التحقق من وجود بطاقات محفوظة
      if (savedCards.isEmpty) {
        print('[DEBUG] ❌ لا توجد بطاقات محفوظة!');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("❌ لا توجد بطاقات محفوظة. يرجى إضافة بطاقة أولاً"),
          backgroundColor: Colors.red,
        ));
        return;
      }

      // التحقق من صحة فهرس البطاقة المختارة
      if (selectedCardIndex >= savedCards.length) {
        print('[DEBUG] ❌ فهرس البطاقة المختارة غير صحيح!');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("❌ خطأ في اختيار البطاقة"),
          backgroundColor: Colors.red,
        ));
        return;
      }

      final selectedCard = savedCards[selectedCardIndex];
      print('[DEBUG] بيانات البطاقة المختارة: cardNumber= {selectedCard.cardNumber}, holderName= {selectedCard.cardHolderName}');
      
      // تحقق من صحة بيانات البطاقة
      if (selectedCard.cardNumber.isEmpty || 
          selectedCard.cardHolderName.isEmpty ||
          selectedCard.cardExpirationDate.isEmpty ||
          selectedCard.cardCVV.isEmpty) {
        print('[DEBUG] ❌ بيانات البطاقة غير مكتملة!');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("❌ بيانات البطاقة غير مكتملة، يرجى اختيار بطاقة أخرى"),
          backgroundColor: Colors.red,
        ));
        return;
      }

      print('[DEBUG] ✅ تم التحقق من البطاقة بنجاح - بطاقة iCredit صحيحة');

      try {
        print('[DEBUG] بدء إنشاء عملية البيع iCreditCreateSale');
        ICreditCreateSaleResponse saleResponse = await iCreditCreateSale(fromList(_con.carts),orderType);
        print('[DEBUG] رد iCreditCreateSale:');
        print('Status: ${saleResponse.status}');
        print('SaleToken: ${saleResponse.saleToken}');
        print('TotalAmount: ${saleResponse.totalAmount}');

        if (saleResponse.status != 0) {
          print('[DEBUG] ❌ فشل في إنشاء عملية البيع');
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("❌ فشل في إنشاء عملية البيع"),
            backgroundColor: Colors.red,
          ));
          return;
        }

        print('[DEBUG] بدء عملية iCreditChargeSimple');
        ICreditChargeSimpleResponse response = await iCreditChargeSimple(
          selectedCard.cardCVV,
          selectedCard.cardHolderName,
          selectedCard.cardNumber,
          selectedCard.cardExpirationDate,
          saleResponse,
        );
        print('[DEBUG] رد iCreditChargeSimple:');
        print('status: ${response.status}');
        print('customerTransactionId: ${response.customerTransactionId}');

        if (response.status == 0) {
          print('[DEBUG] ✅ عملية الدفع نجحت');

          // إنشاء الطلب في النظام
          await _createOrderInSystem(orderType);

          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("✅ تم الدفع بنجاح عبر البطاقة الائتمانية"),
            backgroundColor: Colors.green,
          ));

          // هنا يمكن الانتقال لصفحة النجاح أو تنفيذ الطلب
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => OrderSuccessWidget(
                routeArgument: RouteArgument(
                  param: selectedTap == 1 ? 'iCredit Delivery' : 'iCredit Pickup'
                ),
              ),
            ),
          );
        } else {
          print('[DEBUG] ❌ عملية الدفع عبر iCredit فشلت');
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("❌ فشلت عملية الدفع. حاول مرة أخرى"),
            backgroundColor: Colors.red,
          ));
        }
      } catch (e) {
        print('[DEBUG] ❌ خطأ في عملية الدفع: $e');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("❌ حدث خطأ في عملية الدفع"),
          backgroundColor: Colors.red,
        ));
      }
    }
    // Cash payment disabled - no longer supported
    // else if (selectedPaymentMethod == 'cash') {
    //   print('[DEBUG] ✅ تم اختيار الدفع نقداً');
    //   // Cash payment logic removed
    // }
    else {
      print('[DEBUG] ❌ لم يتم اختيار طريقة دفع');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("❌ يرجى اختيار طريقة دفع"),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_con.list == null) {
      _con.list = PaymentMethodList(context);
    }

    return Scaffold(
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SwipeButtonWidget(
          context: context,
          numOfItems: _con.carts.length,
          onSwipe: () async => await completeSale(),
          totalPrice: returnTheTotal(),
        ),
      ),

      appBar: AppBar(
        forceMaterialTransparency: true,
        centerTitle: true,
        leading: Padding(
          padding: EdgeInsetsDirectional.only(start: 16),
          child: CustomBackButton(
            onTap: () => Navigator.of(context).pushNamedAndRemoveUntil('/cart', (route) => false),
          ),
        ),
        title: Text(
          S.of(context).delivery_or_pickup,
          style: AppTextStyles.font16W600Black,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              CustomTabBar(
                tabs: [
                  TabItem(
                    text: S.of(context).delivery,
                    isSelected: selectedTap == 1,
                    onPressed: () {
                      setState(() => selectedTap = 1);
                      _con.updateSelectedTap(1);
                    },
                  ),
                  TabItem(
                    text: S.of(context).pickup,
                    isSelected: selectedTap == 2,
                    onPressed: () {
                      setState(() => selectedTap = 2);
                      _con.updateSelectedTap(2);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              if (selectedTap == 1) ...[
                _buildAddressField(addressController, () async {
                  print('[DEBUG] فتح قائمة العناوين...');
                  final result = await Navigator.of(context)
                      .pushNamed('/DeliveryAddresses', arguments: [true, _con]);
                  if (result != null && result is Address) {
                    setState(() {
                      _con.deliveryAddress       = result;
                      _con.userDeliverAddress    = result.address ?? '';
                      addressController.text     = _con.userDeliverAddress;  // عرض العنوان الكامل
                    });
                    print('[DEBUG] تم اختيار العنوان: ${result.address}');
                    print('[DEBUG] تم تعيين العنوان في الكنترولر: ${addressController.text}');
                  } else {
                    print('[DEBUG] لم يتم اختيار عنوان من القائمة');
                    // إعادة تعيين العنوان إلى فارغ إذا لم يتم اختيار عنوان
                    setState(() {
                      _con.deliveryAddress = null;
                      _con.userDeliverAddress = '';
                      addressController.text = '';
                    });
                  }
                }),
              ] else ...[
                PaymentMethodCard(
                  title: S.of(context).pickup,
                  image: 'assets/img/shop.svg',
                  isSelected: true,
                  onTap: () {},
                ),
              ],
              const SizedBox(height: 24),
              Text(
                S.of(context).payment_method,
                style: AppTextStyles.font16W600Black,
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => setState(() {
                  showCards = !showCards;
                  selectedPaymentMethod = 'credit';
                  selectedCardIndex = savedCards.isNotEmpty ? selectedCardIndex : -1;
                }),
                child: Container(
                  decoration: BoxDecoration(
                    color: selectedPaymentMethod == 'credit' ? AppColors.cardBgLightColor.withOpacity(0.08) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selectedPaymentMethod == 'credit' ? AppColors.cardBgLightColor : Colors.transparent,
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 5,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  child: Row(
                    children: [
                      SvgPicture.asset('assets/img/card.svg', width: 28, height: 28, color: AppColors.cardBgLightColor),
                      SizedBox(width: 12),
                      Expanded(child: Text(S.of(context).credit_card, style: AppTextStyles.font16W600Black)),
                      if (selectedPaymentMethod == 'credit') Icon(Icons.check, color: AppColors.cardBgLightColor),
                      Icon(showCards ? Icons.expand_less : Icons.expand_more, color: AppColors.cardBgLightColor),
                    ],
                  ),
                ),
              ),
              if (showCards && selectedPaymentMethod == 'credit')
                Column(
                  children: [
                    const SizedBox(height: 8),
                    if (savedCards.isNotEmpty)
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: savedCards.length,
                        itemBuilder: (context, index) {
                          final card = savedCards[index];
                          return Dismissible(
                            key: Key(card.cardNumber + card.cardHolderName),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              color: Colors.red,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  SvgPicture.asset('assets/img/trash.svg', width: 24, height: 24),
                                  SizedBox(width: 8),
                                  Text(S.of(context).delete, style: TextStyle(color: Colors.white)),
                                ],
                              ),
                            ),
                            onDismissed: (direction) async {
                              await Helper.removeCardFromSP(index);
                              await _loadSavedCards();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(S.of(context).card_deleted_successfully),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              if (selectedCardIndex == index) {
                                setState(() => selectedCardIndex = -1);
                              }
                            },
                            child: Container(
                              margin: EdgeInsets.symmetric(vertical: 4),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: selectedCardIndex == index
                                      ? AppColors.cardBgLightColor
                                      : Colors.grey.withOpacity(0.3),
                                  width: 1.5,
                                ),
                                borderRadius: BorderRadius.circular(8),
                                color: selectedCardIndex == index
                                    ? AppColors.cardBgLightColor.withOpacity(0.1)
                                    : Colors.white,
                              ),
                              child: ListTile(
                                leading: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SvgPicture.asset(
                                      'assets/img/card.svg',
                                      width: 28,
                                      height: 28,
                                      color: AppColors.cardBgLightColor
                                    ),
                                  ],
                                ),
                                title: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('**** **** **** ${card.cardNumber.substring(card.cardNumber.length - 4)}'),
                                  ],
                                ),
                                subtitle: Text(card.cardHolderName),
                                trailing: selectedCardIndex == index
                                    ? Icon(Icons.check, color: AppColors.cardBgLightColor)
                                    : null,
                                onTap: () {
                                  setState(() {
                                    selectedCardIndex = index;
                                    selectedPaymentMethod = 'credit';
                                  });
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.cardBgLightColor.withOpacity(0.3)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListTile(
                        leading: SvgPicture.asset(
                          'assets/img/add_card.svg',
                          width: 28,
                          height: 28,
                          color: AppColors.cardBgLightColor
                        ),
                        title: Text(
                          S.of(context).add_credit_card,
                          style: TextStyle(color: AppColors.cardBgLightColor),
                        ),
                        subtitle: Text(
                          S.of(context).add_new_credit_card,
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        onTap: () {
                          setState(() => selectedPaymentMethod = 'credit');
                          Navigator.of(context).pushNamed('/add_new_card').then((result) async {
                            if (result == true || result != null) {
                              await _loadSavedCards();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(S.of(context).card_added_successfully),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          });
                        },
                      ),
                    ),
                    if (savedCards.isEmpty)
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 8),
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue.withOpacity(0.3)),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.credit_card, color: Colors.blue, size: 48),
                            SizedBox(height: 8),
                            Text(
                              S.of(context).no_saved_cards,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              // Cash payment option disabled
              // const SizedBox(height: 8),
              // PaymentMethodCard(
              //   title: S.of(context).cash,
              //   image: 'assets/img/empty-wallet.svg',
              //   isSelected: selectedPaymentMethod.contains('cash'),
              //   onTap: () => setState(() {
              //         selectedPaymentMethod = 'cash';
              //         selectedCardIndex = -1;
              //         showCards = false;
              //       }),
              // ),
              const SizedBox(height: 16),
              _buildPromoCodeField(couponController),
              const SizedBox(height: 24),
              CartBottomDetailsWidget(
                con: _con,
                selectedTap: selectedTap,
              ),
              const SizedBox(height: 150),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPromoCodeField(TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          S.of(context).add_a_promo_code,
          style: AppTextStyles.font16W600Black,
        ),
        SizedBox(height: 8),
        if (_con.coupon.valid == true) ...[
          // عرض الكوبون المطبق
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green, width: 1),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${S.of(context).coupon_applied_short}: ${_con.coupon.code}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      Text(
                        '${S.of(context).discount}: ${_con.coupon.discountType == 'fixed' ? '${_con.coupon.discount} دينار' : '${_con.coupon.discount}%'}',
                        style: TextStyle(color: Colors.green[700]),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: Colors.green),
                  onPressed: () {
                    _con.removeCoupon();
                    controller.clear();
                    setState(() {});
                  },
                ),
              ],
            ),
          ),
        ] else ...[
          // حقل إدخال الكوبون
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: S.of(context).enter_here,
                    prefixIcon: SvgPicture.asset(
                      'assets/img/ticket-discount.svg',
                      width: 18,
                      height: 18,
                      fit: BoxFit.scaleDown,
                      colorFilter: ColorFilter.mode(AppColors.color9D9FA4, BlendMode.srcATop),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                  onSubmitted: (value) {
                    if (value.trim().isNotEmpty) {
                      print('🎫 تم الضغط على Enter: $value');
                      _con.doApplyCoupon(value.trim());
                      setState(() {});
                    }
                  },
                ),
              ),
              SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  print('🎫 تم الضغط على زر التطبيق');
                  if (controller.text.trim().isNotEmpty) {
                    print('🎫 النص المدخل: ${controller.text.trim()}');
                    _con.doApplyCoupon(controller.text.trim());
                    setState(() {});
                  } else {
                    print('🎫 النص فارغ');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('يرجى إدخال رمز الكوبون'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.color26386A,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                child: Text(
                  S.of(context).apply,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildAddressField(
      TextEditingController controller,
      VoidCallback? onChangePressed,
      ) {
    return CustomTextField(
      controller: controller,
      lableText: S.of(context).address,
      hint: controller.text.isEmpty ? S.of(context).address : null,
      // enabled: false, // منع التعديل اليدوي
      prefix: SvgPicture.asset(
        'assets/img/location.svg',
        width: 18,
        height: 18,
        fit: BoxFit.scaleDown,
      ),
      suffix: Padding(
        padding: const EdgeInsets.only(top: 17.5),
        child: Text(
          S.of(context).change,
          style: AppTextStyles.font12W400Grey
              .copyWith(color: AppColors.color26386A),
        ),
      ),
      onSuffixTapped: onChangePressed,
    );
  }
}