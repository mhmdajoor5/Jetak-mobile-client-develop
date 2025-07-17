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
import 'order_success.dart';
import '../models/card_item.dart';
import '../models/icredit_create_sale_body.dart';
import '../repository/icredit_repository.dart';

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

  _DeliveryPickupWidgetState() : super(DeliveryPickupController()) {
    _con = controller as DeliveryPickupController;
  }

  @override
  void initState() {
    super.initState();
    addressController = TextEditingController(text: '');

    if (widget.routeArgument?.param != null && widget.routeArgument!.param is Address) {
      Address selectedAddress = widget.routeArgument!.param as Address;
      _con.deliveryAddress = selectedAddress;
      _con.userDeliverAddress = selectedAddress.address ?? '';
      addressController.text = _con.userDeliverAddress;
    }

    _loadSavedCards();
  }

  @override
  void dispose() {
    addressController.dispose();
    super.dispose();
  }


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

  Future<void> completeSale() async {
    print('--- [DEBUG] بدء عملية الطلب ---');
    if (selectedTap == 1) {
      if (_con.deliveryAddress == null) {
        print('[DEBUG] لم يتم اختيار عنوان!');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('الرجاء اختيار عنوان التوصيل'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

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

    print('[DEBUG] بعد التحقق من التوصيل، أكمل باقي خطوات الطلب');
    // استدعاء دالة الفالديشن والدفع الجديدة
    await _proceedWithPayment();
  }

  Future<void> _proceedWithPayment() async {
    print('[DEBUG] بدء عملية الدفع - طريقة الدفع: $selectedPaymentMethod');

    // فالديشن طريقة الدفع بالبطاقة الائتمانية
    if (selectedPaymentMethod == 'credit') {
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
      // احذف شرط الفالديشن للبطاقة نهائياً
      // ... لا يوجد أي تحقق من صحة البطاقة أو تاريخ الانتهاء أو CVV ...

      print('[DEBUG] ✅ تم التحقق من البطاقة بنجاح - بطاقة iCredit صحيحة');

      try {
        print('[DEBUG] بدء إنشاء عملية البيع iCreditCreateSale');
        ICreditCreateSaleResponse saleResponse = await iCreditCreateSale(fromList(_con.carts));
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
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("✅ تم الدفع بنجاح عبر البطاقة الائتمانية"),
            backgroundColor: Colors.green,
          ));

          // هنا يمكن الانتقال لصفحة النجاح أو تنفيذ الطلب
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => OrderSuccessWidget(
                routeArgument: RouteArgument(param: 'iCredit Payment'),
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
    // Cash payment option disabled
    // else if (selectedPaymentMethod == 'cash') {
    //   print('[DEBUG] ✅ تم اختيار الدفع نقداً');
    //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    //     content: Text("✅ سيتم الدفع نقداً عند التسليم"),
    //     backgroundColor: Colors.green,
    //   ));

    //   // هنا يمكن الانتقال لصفحة النجاح مباشرة
    //   Navigator.pushReplacement(
    //     context,
    //     MaterialPageRoute(
    //       builder: (context) => OrderSuccessWidget(
    //         routeArgument: RouteArgument(param: 'Cash on Delivery'),
    //       ),
    //     ),
    //   );
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
                    onPressed: () => setState(() => selectedTap = 1),
                  ),
                  TabItem(
                    text: S.of(context).pickup,
                    isSelected: selectedTap == 2,
                    onPressed: () => setState(() => selectedTap = 2),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              if (selectedTap == 1) ...[
                _buildAddressField(TextEditingController(), () async {
                  final selectedAddress = await Navigator.of(context).pushNamed('/DeliveryAddresses', arguments: [true, _con]);

                  if (selectedAddress != null && selectedAddress is Address) {
                    setState(() {
                      _con.deliveryAddress = selectedAddress;
                      _con.userDeliverAddress = selectedAddress.address ?? '';
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
              const SizedBox(height: 8),
              // Cash payment option disabled
              // PaymentMethodCard(
              //   title: S.of(context).cash,
              //   image: 'assets/img/empty-wallet.svg',
              //   isSelected: selectedPaymentMethod.contains('cash'),
              //   onTap: () => setState(() {
              //     selectedPaymentMethod = 'cash';
              //     selectedCardIndex = -1;
              //     showCards = false;
              //   }),
              // ),
              const SizedBox(height: 16),
              _buildPromoCodeField(TextEditingController()),
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
    return CustomTextField(
      lableText: S.of(context).add_a_promo_code,
      hint: S.of(context).enter_here,
      prefix: SvgPicture.asset(
        'assets/img/ticket-discount.svg',
        width: 18,
        height: 18,
        fit: BoxFit.scaleDown,
        colorFilter: ColorFilter.mode(AppColors.color9D9FA4, BlendMode.srcATop),
      ),
      suffix: const Icon(
        Icons.arrow_forward_ios,
        size: 12,
        color: AppColors.color9D9FA4,
      ),
      controller: controller,
      onSuffixTapped: () {},
    );
  }

  Widget _buildAddressField(TextEditingController controller, VoidCallback? onChangePressed) {
    return CustomTextField(
      controller: controller,
      lableText:
      _con.userDeliverAddress == ''
          ? S.of(context).address
          : _con.userDeliverAddress.toString(),
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
          style: AppTextStyles.font12W400Grey.copyWith(color: AppColors.color26386A),
        ),
      ),
      onSuffixTapped: onChangePressed,
    );
  }
}