import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../models/card_item.dart';
import '../models/icredit_charge_simple_reesponse.dart';
import '../repository/icredit_repository.dart';

import '../../generated/l10n.dart';
import '../elements/PaymentMethodListItemWidget.dart';
import '../elements/ShoppingCartButtonWidget.dart';
import '../helpers/helper.dart';
import '../models/credit_card.dart';
import '../models/icredit_create_sale_response.dart';
import '../models/payment_method.dart';
import '../models/route_argument.dart';
import '../repository/settings_repository.dart';

class PaymentMethodsWidget extends StatefulWidget {
  final Object? routeArgument;

  PaymentMethodsWidget({Key? key, this.routeArgument}) : super(key: key);

  @override
  _PaymentMethodsWidgetState createState() => _PaymentMethodsWidgetState();
}

class _PaymentMethodsWidgetState extends State<PaymentMethodsWidget> {
  late PaymentMethodList list;
  bool hasCard = false;
  CardItem? currentCard;
  bool isLoading = false;
  List<CardItem> savedCards = [];
  ValueNotifier<int> selectedCardIndex = ValueNotifier<int>(-1);

  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    initHasCard();
    super.initState();
  }

  Future<void> deleteCard(int index) async {
    setState(() {
      savedCards.removeAt(index);
    });
    (await Helper.removeCardFromSP(index));
  }

  @override
  Widget build(BuildContext context) {
    list = new PaymentMethodList(context);
    if (!setting.value.payPalEnabled)
      list.paymentsList.removeWhere((element) {
        return element.id == "paypal";
      });
    if (!setting.value.razorPayEnabled)
      list.paymentsList.removeWhere((element) {
        return element.id == "razorpay";
      });
    if (!setting.value.stripeEnabled)
      list.paymentsList.removeWhere((element) {
        return element.id == "visacard" || element.id == "mastercard";
      });
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: isLoading
              ? null
              : () {
                  Navigator.pop(context);
                },
          icon: Icon(Icons.arrow_back),
          color: Theme.of(context).hintColor,
        ),
        title: Text(
          S.of(context).payment_mode,
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.merge(TextStyle(letterSpacing: 1.3)),
        ),
        actions: <Widget>[
          new ShoppingCartButtonWidget(
              iconColor: Theme.of(context).hintColor,
              labelColor: Theme.of(context).colorScheme.secondary),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      if (savedCards.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: ListTile(
                            contentPadding: EdgeInsets.symmetric(vertical: 0),
                            leading: Icon(
                              Icons.credit_card,
                              color: Theme.of(context).hintColor,
                            ),
                            title: Text(
                                S.of(context).payments,
                              style: Theme.of(context).textTheme.headlineLarge
                            ),
                          ),
                        ),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 10),
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        decoration: BoxDecoration(
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  Theme.of(context).focusColor.withOpacity(0.1),
                              blurRadius: 5,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: InkWell(
                            onTap: () async {
                              CreditCard? newCard = await Navigator.of(context)
                                  .pushNamed('/add_new_card') as CreditCard?;
                              if (newCard != null) {
                                if (!savedCards.any((element) =>
                                element.cardNumber == newCard.number)) {
                                setState(() {
                                  savedCards.add(CardItem(
                                      cardCVV: newCard.cvc,
                                      cardHolderName: newCard.holderName,
                                      cardNumber: newCard.number,
                                      cardExpirationDate: newCard.expiryDate));
                                });

                                  Helper.addCardToSP(CardItem(
                                      cardCVV: newCard.cvc,
                                      cardHolderName: newCard.holderName,
                                      cardNumber: newCard.number,
                                      cardExpirationDate: newCard.expiryDate));
                                }else{
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                    content: Text(S.of(context).card_already_exist ),
                                  ));
                                }
                              }
                            },
                            child: Row(
                              children: [
                                Icon(Icons.add_circle_outline_outlined),
                                SizedBox(
                                  width: 30,
                                ),
                                Text(
                                  S.of(context).add_new_card,
                                  style: Theme.of(context).textTheme.titleMedium,
                                )
                              ],
                            )),
                      ),
                      if (savedCards.isNotEmpty)
                        ListView.builder(
                          shrinkWrap: true,
                          primary: false,
                          itemCount: savedCards.length,
                          itemBuilder: (context, index) {
                            return CardMethodListItemWidget(
                              card: savedCards[index],
                              index: index,
                              onSelected: () {
                                setState(() {
                                  selectedCardIndex.value = index;
                                });
                              },
                              selectedCardIndex: selectedCardIndex,
                            );
                          },
                        ),
                      Divider(),
                      list.cashList.length > 0
                          ? Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 20),
                              child: ListTile(
                                contentPadding:
                                    EdgeInsets.symmetric(vertical: 0),
                                leading: Icon(
                                  Icons.monetization_on,
                                  color: Theme.of(context).hintColor,
                                ),
                                title: Text(
                                  S.of(context).cash_on_delivery,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.headlineLarge
                                ),
                                subtitle: Text(S
                                    .of(context)
                                    .select_your_preferred_payment_mode),
                              ),
                            )
                          : SizedBox(
                              height: 0,
                            ),
                      ListView.separated(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        primary: false,
                        itemCount: list.cashList.length,
                        separatorBuilder: (context, index) {
                          return SizedBox(height: 10);
                        },
                        itemBuilder: (context, index) {
                          return PaymentMethodListItemWidget(
                              paymentMethod: list.cashList.elementAt(index),
                              routeArgument: widget.routeArgument
                                  as ICreditCreateSaleResponse);
                        },
                      ),
                    ],
                  ),
                  Visibility(
                    visible: isLoading,
                    child: InkWell(
                      onTap: () {},
                      child: Container(
                        color: Colors.grey.withOpacity(0.6),
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width,
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Container(
                      color: Colors.white,
                      padding: EdgeInsets.all(15),
                      child: ElevatedButton(
                        onPressed: isLoading
                            ? null
                            : () {
                                completeSale();
                              },
                        child: Text(S.of(context).complete_order),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              )
            ],
          ),
        ],
      ),
    );
  }

  void initHasCard() async {
    hasCard = (await Helper.getSavedCards()).isNotEmpty;
    // currentCard = await Helper.getCurrentCreditCard();
    print("hasCard: " + hasCard.toString());
    savedCards = await Helper.getSavedCards();

    setState(() {});
  }

  Future<void> completeSale() async {
    print('--- بدء عملية الدفع عبر iCredit (payment_methods.dart) ---');
    if (selectedCardIndex.value == -1) {
      print('لم يتم اختيار أي بطاقة!');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Please select a card"),
      ));
      return;
    }

    final selectedCard = savedCards[selectedCardIndex.value];
    print('بيانات البطاقة: cardNumber=${selectedCard.cardNumber}, holderName=${selectedCard.cardHolderName}, expDateYymm=${selectedCard.cardExpirationDate}, cvv=${selectedCard.cardCVV}');
    setState(() {
      isLoading = true;
    });

    try {
      ICreditChargeSimpleResponse response = await iCreditChargeSimple(
        selectedCard.cardCVV,
        selectedCard.cardHolderName,
        selectedCard.cardNumber,
        selectedCard.cardExpirationDate,
        widget.routeArgument as ICreditCreateSaleResponse,
      );
      print('رد iCreditChargeSimple:');
      print(response);
      print('status: [32m${response.status}[0m, customerTransactionId: ${response.customerTransactionId}');

      if (response.status == 0) {
        print('--- عملية الدفع عبر iCredit نجحت (payment_methods.dart) ---');
        // تم حذف الانتقال المباشر لشاشة النجاح هنا
        // دع الكنترولر يدير الانتقال بعد نجاح الطلب
      } else {
        print('--- عملية الدفع عبر iCredit فشلت (payment_methods.dart) ---');
        showPaymentFailureSheet();
      }
    } catch (e) {
      print("Error completing sale: $e");
      showPaymentFailureSheet();
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void showPaymentFailureSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.credit_card_off, size: 50, color: Colors.red),
              SizedBox(height: 20),
              Text(
                S.of(context).transaction_declined,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              SizedBox(height: 10),
              Text(
                S.of(context).tips_complete_order,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SizedBox(height: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(S.of(context).tip_check_card_info),
                  Text(S.of(context).tip_use_different_card),
                  Text(S.of(context).tip_contact_issuer),
                ],
              ),
              SizedBox(height: 20),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(S.of(context).go_back_checkout),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class CardMethodListItemWidget extends StatelessWidget {
  final CardItem card;
  final int index;
  final ValueNotifier<int> selectedCardIndex; // Tracks the selected card
  final VoidCallback? onSelected; // Callback when a card is selected

  CardMethodListItemWidget({
    Key? key,
    required this.card,
    required this.index,
    required this.selectedCardIndex,
    this.onSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: ValueListenableBuilder<int>(
        valueListenable: selectedCardIndex,
        builder: (context, selectedIndex, _) {
          return InkWell(
            onTap: () {
              selectedCardIndex.value = index; // Update the selected card index
              if (onSelected != null) {
                onSelected!(); // Trigger the callback
              }
            },
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 10),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).focusColor.withOpacity(0.1),
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Radio<int>(
                    value: index,
                    groupValue: selectedIndex, // Highlight the selected card
                    onChanged: (value) {
                      if (value != null){
                        selectedCardIndex.value = value; // Update selected index
                      }
                      if (onSelected != null) {
                        onSelected!(); // Trigger the callback
                      }
                    },
                  ),
                  Container(
                    height: 35,
                    width: 35,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                    ),
                    child: SvgPicture.asset(
                      _getCardIcon(card.cardNumber),
                      height: 36,
                      width: 36,
                    ),
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  Flexible(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                card.cardHolderName,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              Text(
                                "Pay using card XXXX-XXXX-XXXX-${card.cardNumber.substring(card.cardNumber.length - 4)}",
                                overflow: TextOverflow.ellipsis,
                                softWrap: false,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 8),
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _getCardIcon(String cardNumber) {
    if (cardNumber.startsWith(RegExp(r'^4'))) {
      return "assets/img/credit-card.svg"; // Icon for Visa
    } else if (cardNumber.startsWith(RegExp(r'^5[1-5]'))) {
      return "assets/img/mastercard.svg"; // Icon for MasterCard
    }
    return "assets/img/credit-card.svg"; // Default icon
  }
}
