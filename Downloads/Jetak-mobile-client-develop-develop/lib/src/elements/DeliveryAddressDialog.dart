import 'package:flutter/material.dart';

import '../../generated/l10n.dart';
import '../helpers/checkbox_form_field.dart';
import '../models/address.dart';

// ignore: must_be_immutable
class DeliveryAddressDialog {
  BuildContext context;
  Address address;
  ValueChanged<Address> onChanged;
  final GlobalKey<FormState> _deliveryAddressFormKey = GlobalKey<FormState>();

  DeliveryAddressDialog({required this.context, required this.address, required this.onChanged}) {
    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          titlePadding: EdgeInsets.fromLTRB(16, 25, 16, 0),
          title: Row(
            children: <Widget>[Icon(Icons.place, color: Theme.of(context).hintColor), SizedBox(width: 10), Text(S.of(context).add_delivery_address, style: Theme.of(context).textTheme.bodyLarge)],
          ),
          children: <Widget>[
            Form(
              key: _deliveryAddressFormKey,
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextFormField(
                      style: TextStyle(color: Theme.of(context).hintColor),
                      keyboardType: TextInputType.text,
                      decoration: getInputDecoration(hintText: S.of(context).home_address, labelText: S.of(context).description),
                      initialValue: address.description?.isNotEmpty == true ? address.description : null,
                      validator: (input) => (input == null || input.trim().isEmpty) ? 'Not valid address description' : null,
                      onSaved: (input) => address.description = input ?? '',
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextFormField(
                      style: TextStyle(color: Theme.of(context).hintColor),
                      keyboardType: TextInputType.text,
                      decoration: getInputDecoration(hintText: S.of(context).hint_full_address, labelText: S.of(context).full_address),
                      initialValue: address.address?.isNotEmpty == true ? address.address : null,
                      validator: (input) => (input == null || input.trim().isEmpty) ? S.of(context).notValidAddress : null,
                      onSaved: (input) => address.address = input ?? '',
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: CheckboxFormField(context: context, initialValue: address.isDefault ?? false, onSaved: (input) => address.isDefault = input, title: Text(S.of(context).makeItDefault)),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                MaterialButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(S.of(context).cancel, style: TextStyle(color: Theme.of(context).hintColor)),
                ),
                MaterialButton(onPressed: _submit, child: Text(S.of(context).save, style: TextStyle(color: Theme.of(context).colorScheme.secondary))),
              ],
            ),
            SizedBox(height: 10),
          ],
        );
      },
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
    if (_deliveryAddressFormKey.currentState!.validate()) {
      _deliveryAddressFormKey.currentState!.save();
      onChanged(address);
      Navigator.pop(context);
    }
  }
}
