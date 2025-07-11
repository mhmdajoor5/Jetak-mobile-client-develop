import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import '../../generated/l10n.dart';
import '../controllers/settings_controller.dart';
import '../elements/CircularLoadingWidget.dart';
import '../elements/MobileVerificationBottomSheetWidget.dart';
import '../elements/PaymentSettingsDialog.dart';
import '../elements/ProfileSettingsDialog.dart';
import '../helpers/helper.dart';
import '../repository/user_repository.dart';

class SettingsWidget extends StatefulWidget {
  @override
  _SettingsWidgetState createState() => _SettingsWidgetState();
}

class _SettingsWidgetState extends StateMVC<SettingsWidget> {
  late SettingsController _con;
  _SettingsWidgetState() : super(SettingsController()) {
    _con = controller as SettingsController;
  }

  @override
  void initState() {
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
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back),
          color: Theme.of(context).hintColor,
        ),
        title: Text(
          S.of(context).settings,
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.merge(TextStyle(letterSpacing: 1.3)),
        ),
      ),
      body: currentUser.value.id == null
          ? CircularLoadingWidget(height: 500)
          : ListView(
        padding: EdgeInsets.symmetric(vertical: 16),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentUser.value.name!,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        currentUser.value.email!,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),

                    ],
                  ),
                ),
                SizedBox(
                  width: 55,
                  height: 55,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(300),
                    onTap: () => Navigator.of(context).pushNamed('/Profile'),
                    child: CircleAvatar(
                      backgroundImage:
                      NetworkImage(currentUser.value.image!.thumb),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Divider(height: 1),

          // Profile Settings
          ListTile(
            //leading: Icon(Icons.person),
            title: Text(
              S.of(context).profile_settings,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            trailing: ProfileSettingsDialog(
              user: currentUser.value,
              onChanged: () async {
                await _con.update(currentUser.value);
                if (!currentUser.value.verifiedPhone!) {
                  var bs = _con.scaffoldKey.currentState?.showBottomSheet(
                        (ctx) => MobileVerificationBottomSheetWidget(
                        scaffoldKey: _con.scaffoldKey,
                        user: currentUser.value),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(10))),
                  );
                  bs?.closed.then((_) => _con.update(currentUser.value));
                }
              },
            ),
          ),
          Divider(height: 1),

          ListTile(
            dense: true,
            title: Text(S.of(context).full_name,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            trailing: Text(
              Helper.limitString(currentUser.value.bio!),
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Divider(height: 1),

          ListTile(
            dense: true,
            title: Text(S.of(context).email,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            trailing: Text(
              Helper.limitString(currentUser.value.bio!),
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Divider(height: 1),

          ListTile(
            dense: true,
            title: Wrap(
              spacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  S.of(context).phone,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                if (currentUser.value.verifiedPhone ?? false)
                  Icon(
                    Icons.check_circle_outline,
                    color: Theme.of(context).colorScheme.secondary,
                    size: 20,
                  ),
              ],
            ),
            trailing: Text(
              currentUser.value.phone ?? '',
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          Divider(height: 1),

          ListTile(
            dense: true,
            title: Text(S.of(context).address,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            trailing: Text(
              Helper.limitString(currentUser.value.bio!),
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Divider(height: 1),

          ListTile(
            dense: true,
            title: Text(
              S.of(context).about,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            trailing: Text(
              Helper.limitString(currentUser.value.bio!),
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          Divider(height: 1),

          // Payment Settings
          ListTile(
            leading: Icon(Icons.credit_card),
            title: Text(
              S.of(context).payments_settings,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            trailing: PaymentSettingsDialog(
              creditCard: _con.creditCard,
              onChanged: () {
                _con.updateCreditCard(_con.creditCard);
                setState(() {});
              },
            ),
          ),
          Divider(height: 1),

          ListTile(
            dense: true,
            title: Text(S.of(context).default_credit_card,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            trailing: Text(
              _con.creditCard.number.isNotEmpty
                  ? '•••• ' +
                  _con.creditCard.number.substring(
                      _con.creditCard.number.length - 4)
                  : '',
              style: TextStyle(color: Theme.of(context).focusColor,fontWeight: FontWeight.bold,),
            ),
          ),
          Divider(height: 1),

          // App Settings
          ListTile(
            leading: Icon(Icons.settings),
            title: Text(
              S.of(context).app_settings,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Divider(height: 1),

          ListTile(
            leading: Icon(Icons.place),
            title: Text(S.of(context).delivery_addresses,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            onTap: () => Navigator.of(context)
                .pushNamed('/DeliveryAddresses', arguments: false),
          ),
          Divider(height: 1),

          ListTile(
            leading: Icon(Icons.help),
            title: Text(S.of(context).help_support,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            onTap: () => Navigator.of(context).pushNamed('/Help'),
          ),
          Divider(height: 1),
        ],
      ),
    );
  }
}
