import 'package:flutter/material.dart';

import '../../generated/l10n.dart';
import '../elements/PaymentSettingsDialog.dart';
import '../helpers/helper.dart';
import '../models/credit_card.dart';

// ignore: must_be_immutable
class CreditCardsWidget extends StatelessWidget {
  final CreditCard creditCard;
  final ValueChanged<CreditCard> onChanged;

  CreditCardsWidget({Key? key, required this.creditCard, required this.onChanged}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.topCenter,
      children: <Widget>[
        Container(
          width: 259,
          height: 165,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.8),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [BoxShadow(color: Theme.of(context).hintColor.withOpacity(0.15), blurRadius: 20, offset: Offset(0, 5))],
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 12),
          width: 275,
          height: 177,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.8),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [BoxShadow(color: Theme.of(context).hintColor.withOpacity(0.15), blurRadius: 20, offset: Offset(0, 5))],
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 25),
          width: 300,
          height: 195,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [BoxShadow(color: Theme.of(context).hintColor.withOpacity(0.15), blurRadius: 20, offset: Offset(0, 5))],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 21),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Image.asset('assets/img/visa.png', height: 22, width: 70),
                    SizedBox(
                      height: 24,
                      child: PaymentSettingsDialog(
                        creditCard: creditCard,
                        onChanged: () {
                          onChanged(creditCard);
                        },
                      ),
                    ),
                  ],
                ),
                Text(S.of(context).card_number, style: Theme.of(context).textTheme.bodySmall),
                Text(Helper.getCreditCardNumber(creditCard.number), style: Theme.of(context).textTheme.bodyLarge!.merge(TextStyle(letterSpacing: 1.4))),
                SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[Text(S.of(context).expiry_date, style: Theme.of(context).textTheme.bodySmall), Text(S.of(context).cvv, style: Theme.of(context).textTheme.bodySmall)],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text('${creditCard.expMonth}/${creditCard.expYear}', style: Theme.of(context).textTheme.bodyLarge!.merge(TextStyle(letterSpacing: 1.4))),
                    Text(creditCard.cvc, style: Theme.of(context).textTheme.bodyLarge!.merge(TextStyle(letterSpacing: 1.4))),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
