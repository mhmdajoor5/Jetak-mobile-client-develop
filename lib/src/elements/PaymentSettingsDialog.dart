import 'package:flutter/material.dart';

import '../../generated/l10n.dart';
import '../models/credit_card.dart';

// ignore: must_be_immutable
class PaymentSettingsDialog extends StatefulWidget {
  CreditCard creditCard;
  VoidCallback onChanged;

  PaymentSettingsDialog({Key? key, required this.creditCard, required this.onChanged}) : super(key: key);

  @override
  _PaymentSettingsDialogState createState() => _PaymentSettingsDialogState();
}

class _PaymentSettingsDialogState extends State<PaymentSettingsDialog> {
  final GlobalKey<FormState> _paymentSettingsFormKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      elevation: 0,
      focusElevation: 0,
      highlightElevation: 0,
      onPressed: () async {
        final Object? creditCard = await Navigator.of(context).pushNamed("/iCredit");
        if (creditCard is CreditCard) {
          widget.creditCard.expMonth = creditCard.expiryDate.split('/').elementAt(0);
          widget.creditCard.expYear = creditCard.expiryDate.split('/').elementAt(1);
          widget.creditCard.cvc = creditCard.cvc;
          widget.creditCard.number = creditCard.number;
          widget.creditCard = creditCard;
          widget.onChanged();
        }
      },
      child: Text(S.of(context).edit, style: Theme.of(context).textTheme.bodyMedium),
    );
  }

  InputDecoration getInputDecoration({required String hintText, required String labelText}) {
    return InputDecoration(
      hintText: hintText,
      labelText: labelText,
      hintStyle: Theme.of(context).textTheme.bodyMedium?.merge(TextStyle(color: Theme.of(context).focusColor)),
      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).hintColor.withOpacity(0.2))),
      focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).hintColor)),
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      labelStyle: Theme.of(context).textTheme.bodyMedium?.merge(TextStyle(color: Theme.of(context).hintColor)),
    );
  }

  void _submit() {
    if (_paymentSettingsFormKey.currentState?.validate() ?? false) {
      _paymentSettingsFormKey.currentState?.save();
      widget.onChanged();
      Navigator.pop(context);
    }
  }
}
