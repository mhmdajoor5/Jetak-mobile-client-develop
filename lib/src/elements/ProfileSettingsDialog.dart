import 'package:flutter/material.dart';

import '../../generated/l10n.dart';
import '../models/user.dart';

class ProfileSettingsDialog extends StatefulWidget {
  final User user;
  final VoidCallback onChanged;

  ProfileSettingsDialog({Key? key, required this.user, required this.onChanged}) : super(key: key);

  @override
  _ProfileSettingsDialogState createState() => _ProfileSettingsDialogState();
}

class _ProfileSettingsDialogState extends State<ProfileSettingsDialog> {
  final GlobalKey<FormState> _profileSettingsFormKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      elevation: 0,
      focusElevation: 0,
      highlightElevation: 0,
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) {
            return Container();
          },
        );
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
    if (_profileSettingsFormKey.currentState?.validate() ?? false) {
      _profileSettingsFormKey.currentState?.save();
      widget.onChanged();
      Navigator.pop(context);
    }
  }
}
