import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../controllers/checkout_controller.dart';
import '../elements/CircularLoadingWidget.dart';
import '../elements/CreditCardsWidget.dart';
import '../helpers/helper.dart';
import '../models/payment.dart';
import '../repository/settings_repository.dart';

class CheckoutWidget extends StatefulWidget {
  @override
  _CheckoutWidgetState createState() => _CheckoutWidgetState();
}

class _CheckoutWidgetState extends StateMVC<CheckoutWidget> {
  late CheckoutController _con;
  String selectedOrderType = 'delivery';

  _CheckoutWidgetState() : super(CheckoutController()) {
    _con = controller as CheckoutController;
  }

  @override
  void initState() {
    _con.listenForCarts();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _con.scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          S.of(context).checkout,
          style: Theme.of(context).textTheme.headlineSmall
              ?.merge(TextStyle(letterSpacing: 1.3)),
        ),
      ),
      body: _con.carts.isEmpty
          ? CircularLoadingWidget(height: 400)
          : Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(bottom: 255),
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Padding(
                    padding:
                    const EdgeInsets.only(left: 20, right: 10),
                    child: ListTile(
                      leading: Icon(Icons.payment,
                          color: Theme.of(context).hintColor),
                      title: Text(S.of(context).payment_mode,
                          style: Theme.of(context)
                              .textTheme
                              .headlineLarge),
                      subtitle: Text(S
                          .of(context)
                          .select_your_preferred_payment_mode),
                    ),
                  ),
                  SizedBox(height: 20),
                  CreditCardsWidget(
                    creditCard: _con.creditCard,
                    onChanged: (card) => _con.updateCreditCard(card),
                  ),
                  SizedBox(height: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          S.of(context).chooseOrderType,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      ListTile(
                        title:  Text(S.of(context).delivery),
                        leading: Radio<String>(
                          value: 'delivery',
                          groupValue: selectedOrderType,
                          onChanged: (value) {
                            setState(() {
                              selectedOrderType = value!;
                            });
                          },
                        ),
                      ),
                      ListTile(
                        title:  Text(S.of(context).pickup),
                        leading: Radio<String>(
                          value: 'pickup',
                          groupValue: selectedOrderType,
                          onChanged: (value) {
                            setState(() {
                              selectedOrderType = value!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 40),
                  if (setting.value.payPalEnabled) ...[
                    Text(S.of(context).or_checkout_with),
                    SizedBox(height: 20),
                    SizedBox(
                      width: 320,
                      child: MaterialButton(
                        onPressed: () {
                          Navigator.of(context)
                              .pushReplacementNamed('/PayPal');
                        },
                        padding: EdgeInsets.symmetric(
                            vertical: 12),
                        shape: StadiumBorder(),
                        color: Theme.of(context)
                            .focusColor
                            .withOpacity(0.2),
                        child: Image.asset(
                            'assets/img/paypal2.png',
                            height: 28),
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: 255,
              padding: EdgeInsets.symmetric(
                  horizontal: 20, vertical: 15),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.vertical(
                    top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                      color:
                      Theme.of(context).focusColor.withOpacity(0.15),
                      blurRadius: 5,
                      offset: Offset(0, -2))
                ],
              ),
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                          child: Text(S.of(context).estimated_time)),
                      Helper.getPrice(_con.estimatedTime.toDouble(),
                          context),
                    ],
                  ),
                  SizedBox(height: 3),
                  Row(
                    children: <Widget>[
                      Expanded(child: Text(S.of(context).subtotal)),
                      Helper.getPrice(_con.subTotal, context),
                    ],
                  ),
                  SizedBox(height: 3),
                  Row(
                    children: <Widget>[
                      Expanded(child: Text(S.of(context).delivery_fee)),
                      Helper.getPrice(
                          _con.carts[0].food?.restaurant.deliveryFee ??
                              0,
                          context),
                    ],
                  ),
                  SizedBox(height: 3),
                  // تم إزالة عرض الضريبة لأن الأسعار تدخل مع الضريبة مسبقاً
                  // Row(
                  //   children: <Widget>[
                  //     Expanded(
                  //         child: Text(
                  //             "${S.of(context).tax} (${_con.carts[0].food?.restaurant.defaultTax}%)")),
                  //     Helper.getPrice(_con.taxAmount, context),
                  //   ],
                  // ),
                  Divider(height: 30),
                  Row(
                    children: <Widget>[
                      Expanded(
                          child: Text(S.of(context).total,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall)),
                      Helper.getPrice(_con.total, context,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall),
                    ],
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    width: MediaQuery.of(context).size.width - 40,
                    child: _con.loading
                        ? Center(child: CircularProgressIndicator())
                        : MaterialButton(
                      onPressed: () {
                        if (_con.creditCard.validated()) {
                          setState(() {
                            _con.loading = true;
                          });

                          _con.payment = Payment(method: 'Credit Card');
                          _con.onLoadingCartDone();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(S.of(context).your_credit_card_not_valid),
                            ),
                          );
                        }
                      },
                      padding: EdgeInsets.symmetric(vertical: 14),
                      color: Theme.of(context).colorScheme.secondary,
                      shape: StadiumBorder(),
                      child: Text(
                        S.of(context).confirm_payment,
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                    ),
                  SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
