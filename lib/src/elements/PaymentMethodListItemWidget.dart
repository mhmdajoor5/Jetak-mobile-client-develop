import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/icredit_create_sale_response.dart';

import '../helpers/custom_trace.dart';
import '../models/payment_method.dart';

class PaymentMethodListItemWidget extends StatelessWidget {
  final String? heroTag;
  final bool? hasCard;
  final String? cardNumber;
  final PaymentMethod? paymentMethod;
  final VoidCallback? onPressed;
  final ICreditCreateSaleResponse? routeArgument;

  PaymentMethodListItemWidget({Key? key, this.heroTag, this.hasCard, this.cardNumber, this.paymentMethod, this.onPressed, this.routeArgument}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String lastFourDigits = _getLastFourDigits(cardNumber);
    String cardIcon = _getCardIcon(cardNumber);

    return InkWell(
      splashColor: Theme.of(context).colorScheme.secondary,
      focusColor: Theme.of(context).colorScheme.secondary,
      highlightColor: Theme.of(context).primaryColor,
      onTap:
          onPressed ??
          () {
            if (paymentMethod != null) {
              Navigator.of(context).pushNamed(paymentMethod!.route, arguments: routeArgument);
              print(CustomTrace(StackTrace.current, message: paymentMethod!.name));
            }
          },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.9),
          boxShadow: [BoxShadow(color: Theme.of(context).focusColor.withOpacity(0.1), blurRadius: 5, offset: Offset(0, 2))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(5))),
              child:
                  (paymentMethod?.id != "icredit")
                      ? Container(
                        height: 60,
                        width: 60,
                        decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(5)), image: DecorationImage(image: AssetImage(paymentMethod?.logo ?? ''), fit: BoxFit.fill)),
                      )
                      : SvgPicture.asset(cardIcon, height: 36, width: 36),
            ),
            SizedBox(width: 15),
            Flexible(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(paymentMethod?.name ?? '', overflow: TextOverflow.ellipsis, maxLines: 2, style: Theme.of(context).textTheme.titleMedium),
                        Visibility(
                          visible: (paymentMethod?.description.isNotEmpty ?? false),
                          child: Text(paymentMethod?.description ?? '', overflow: TextOverflow.fade, softWrap: false, style: Theme.of(context).textTheme.bodySmall),
                        ),
                        Visibility(
                          visible: hasCard ?? false,
                          child: Text("Pay using card XXXX-XXXX-XXXX-$lastFourDigits", overflow: TextOverflow.ellipsis, softWrap: false, style: Theme.of(context).textTheme.bodySmall),
                        ),
                        Visibility(
                          visible: hasCard ?? false,
                          child: SizedBox(
                            width: 64,
                            child: TextButton(
                              style: TextButton.styleFrom(padding: EdgeInsets.zero),
                              onPressed: () {
                                if (paymentMethod != null) {
                                  Navigator.of(context).pushNamed(paymentMethod!.route, arguments: routeArgument);
                                }
                              },
                              child: Row(children: [Text("Change", style: TextStyle(fontSize: 12)), SizedBox(width: 6), Icon(Icons.edit, size: 12)]),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.keyboard_arrow_right, color: Theme.of(context).focusColor),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getLastFourDigits(String? cardNumber) {
    if (cardNumber == null || cardNumber.length < 4) return "0000";
    return cardNumber.substring(cardNumber.length - 4);
  }

  String _getCardIcon(String? cardNumber) {
    if (cardNumber == null) return paymentMethod?.logo ?? "";
    if (cardNumber.startsWith(RegExp(r'^4'))) {
      return "assets/img/credit-card.svg"; // Icon for Visa
    } else if (cardNumber.startsWith(RegExp(r'^5[1-5]'))) {
      return "assets/img/mastercard.svg"; // Icon for MasterCard
    }
    return "assets/img/credit-card.svg"; // Default icon
  }
}
