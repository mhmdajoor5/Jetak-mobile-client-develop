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

  _DeliveryPickupWidgetState() : super(DeliveryPickupController()) {
    _con = controller as DeliveryPickupController;
  }

  @override
  void initState() {
    super.initState();
    _loadSavedCards();
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
    if (selectedPaymentMethod == 'credit' && selectedCardIndex != -1) {
      print('[DEBUG] طريقة الدفع: بطاقة ائتمان، بطاقة مختارة: $selectedCardIndex');
      if (selectedCardIndex == -1) {
        print('[DEBUG] لم يتم اختيار أي بطاقة!');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Please select a card"),
        ));
        return;
      }

      final selectedCard = savedCards[selectedCardIndex];
      print('[DEBUG] بيانات البطاقة: cardNumber=${selectedCard.cardNumber}, holderName=${selectedCard.cardHolderName}, expDateYymm=${selectedCard.cardExpirationDate}, cvv=${selectedCard.cardCVV}');
      setState(() {
        // isLoading = true;
      });

      try {
        print('[DEBUG] بدء إنشاء عملية البيع iCreditCreateSale');
        ICreditCreateSaleResponse saleResponse = await iCreditCreateSale(fromList(_con.carts));
        print('[DEBUG] رد iCreditCreateSale:');
        print(saleResponse.clientMessage);
        print(saleResponse.debugMessage);
        print(saleResponse.status);
        print(saleResponse.saleToken);
        print(saleResponse.creditboxToken);
        print(saleResponse.totalAmount);
        
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
        print('amount: ${response.amount}');
        print('customerTransactionId: ${response.customerTransactionId}');
        print('token: ${response.token}');

        if (response.status == 0) {
          print('[DEBUG] --- عملية الدفع عبر iCredit نجحت (DeliveryPickupWidget) ---');
          // تم حذف الانتقال المباشر لشاشة النجاح هنا
          // دع الكنترولر يدير الانتقال بعد نجاح الطلب
        } else {
          print('[DEBUG] --- عملية الدفع عبر iCredit فشلت (DeliveryPickupWidget) ---');
          String errorMessage = 'فشلت عملية الدفع';
          if (response.status == 4) {
            errorMessage = 'تم رفض البطاقة من قبل البنك. يرجى التحقق من:\n'
                '• رصيد البطاقة كافٍ\n'
                '• بيانات البطاقة صحيحة\n'
                '• البطاقة مفعلة وغير محظورة';
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 5),
              action: SnackBarAction(
                label: 'حسناً',
                textColor: Colors.white,
                onPressed: () {},
              ),
            ),
          );
        }
      } catch (e) {
        print("[DEBUG] Error completing sale: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ أثناء عملية الدفع'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          // isLoading = false;
        });
      }
    } else {
      print('[DEBUG] طريقة الدفع ليست بطاقة ائتمان أو لم يتم اختيار بطاقة.');
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => OrderSuccessWidget(
            routeArgument: RouteArgument(
              param: selectedTap == 1 ? 'Cash on Delivery' : 'Pay on Pickup',
            ),
          ),
        ),
      );
      // تم حذف الانتقال المباشر لشاشة النجاح هنا أيضاً
      // دع الكنترولر يدير الانتقال بعد نجاح الطلب
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
          child: CustomBackButton(onTap: () => Navigator.pop(context)),
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
                  var address = await Navigator.of(context).pushNamed('/DeliveryAddresses', arguments: [true,_con]);
                  if (address != null) {
                    setState(() {
                      _con.deliveryAddress = address as Address;
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
                            child: ListTile(
                              leading: SvgPicture.asset('assets/img/card.svg', width: 28, height: 28, color: AppColors.cardBgLightColor),
                              title: Text('**** **** **** ${card.cardNumber.substring(card.cardNumber.length - 4)}'),
                              subtitle: Text(card.cardHolderName),
                              trailing: selectedCardIndex == index ? Icon(Icons.check, color: AppColors.cardBgLightColor) : null,
                              onTap: () {
                                setState(() {
                                  selectedCardIndex = index;
                                  selectedPaymentMethod = 'credit';
                                });
                              },
                            ),
                          );
                        },
                      ),
                    ListTile(
                      leading: SvgPicture.asset('assets/img/add_card.svg', width: 28, height: 28, color: AppColors.cardBgLightColor),
                      title: Text('add_new_card'),
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
                  ],
                ),
              const SizedBox(height: 8),
              PaymentMethodCard(
                title: S.of(context).cash,
                image: 'assets/img/empty-wallet.svg',
                isSelected: selectedPaymentMethod.contains('cash'),
                onTap: () => setState(() {
                  selectedPaymentMethod = 'cash';
                  selectedCardIndex = -1;
                  showCards = false;
                }),
              ),
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