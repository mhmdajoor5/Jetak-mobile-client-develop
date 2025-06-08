import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import '../../generated/l10n.dart';
import '../controllers/checkout_controller.dart';
import '../elements/CircularLoadingWidget.dart';
import '../elements/CreditCardsWidget.dart';
import '../helpers/helper.dart';
import '../models/route_argument.dart';

class CheckoutWidget extends StatefulWidget {
  @override
  _CheckoutWidgetState createState() => _CheckoutWidgetState();
}

class _CheckoutWidgetState extends StateMVC<CheckoutWidget> {
  late CheckoutController _con;

  _CheckoutWidgetState() : super(CheckoutController()) {
    _con = controller as CheckoutController;
  }

  @override
  void initState() {
    super.initState();
    _con.listenForCarts();
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
          style: Theme.of(context).textTheme.headlineSmall?.merge(
            TextStyle(letterSpacing: 1.3),
          ),
        ),
      ),
      body: _con.carts.isEmpty
          ? CircularLoadingWidget(height: 400)
          : Stack(
        fit: StackFit.expand,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 255),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ListTile(
                      leading: Icon(Icons.payment, color: Theme.of(context).hintColor),
                      title: Text(
                        S.of(context).payment_mode,
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                      subtitle: Text(
                        S.of(context).select_your_preferred_payment_mode,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  CreditCardsWidget(
                    creditCard: _con.creditCard,
                    onChanged: (card) => _con.updateCreditCard(card),
                  ),
                  if (!_con.isWithinDeliveryRange)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20),
                      child: Row(
                        children: [
                          Icon(Icons.warning, color: Colors.orange),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Your address is outside the delivery area. Pickup only is available.',
                              style: TextStyle(color: Colors.orange),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            child: Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, -2))],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(S.of(context).subtotal, style: Theme.of(context).textTheme.bodyLarge),
                      Helper.getPrice(_con.subTotal, context),
                    ],
                  ),
                  SizedBox(height: 8),
                  if (_con.isWithinDeliveryRange && (_con.carts[0].food?.restaurant.deliveryFee ?? 0) > 0)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(S.of(context).delivery_fee, style: Theme.of(context).textTheme.bodyLarge),
                        Helper.getPrice(_con.carts[0].food?.restaurant.deliveryFee ?? 0, context),
                      ],
                    ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${S.of(context).tax} (${_con.carts[0].food?.restaurant.defaultTax}%)",
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      Helper.getPrice(_con.taxAmount, context),
                    ],
                  ),
                  Divider(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(S.of(context).total, style: Theme.of(context).textTheme.headlineSmall),
                      Helper.getPrice(_con.total, context),
                    ],
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (!_con.creditCard.validated()) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(S.of(context).your_credit_card_not_valid)),
                          );
                          return;
                        }

                        if (!_con.isWithinDeliveryRange) {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('Out of Delivery Range'),
                              content: Text('Your address is out of the delivery range. Please select pickup or change your address.'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: Text('OK'),
                                ),
                              ],
                            ),
                          );
                          return;
                        }

                        Navigator.of(context).pushNamed(
                          '/OrderSuccess',
                          arguments: RouteArgument(param: 'Credit Card (Stripe Gateway)'),
                        );
                      },
                      child: Text(S.of(context).confirm_payment),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: StadiumBorder(),
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

