import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import '../../generated/l10n.dart';
import '../controllers/settings_controller.dart';
import '../elements/CircularLoadingWidget.dart';
import '../elements/MobileVerificationBottomSheetWidget.dart';
import '../elements/PaymentSettingsDialog.dart';
import '../elements/ProfileSettingsDialog.dart';
import '../elements/SearchBarWidget.dart';
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
  Widget build(BuildContext context) {
    return Scaffold(
        key: _con.scaffoldKey,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back),
            color: Theme.of(context).hintColor,
          ),
          title: Text(
            S.of(context).settings,
            style: Theme.of(context).textTheme.headlineSmall?.merge(TextStyle(letterSpacing: 1.3)),
          ),
        ),
        body: currentUser.value.id == null
            ? CircularLoadingWidget(height: 500)
            : SingleChildScrollView(
                padding: EdgeInsets.symmetric(vertical: 7),
                child: Column(
                  children: <Widget>[
                    // Padding(
                    //   padding: const EdgeInsets.symmetric(horizontal: 20),
                    //   child: SearchBarWidget(),
                    // ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Column(
                              children: <Widget>[
                                Text(
                                  currentUser.value.name!,
                                  textAlign: TextAlign.left,
                                  style: Theme.of(context).textTheme.displaySmall,
                                ),
                                Text(
                                  currentUser.value.email!,
                                  style: Theme.of(context).textTheme.bodySmall,
                                )
                              ],
                              crossAxisAlignment: CrossAxisAlignment.start,
                            ),
                          ),
                          SizedBox(
                              width: 55,
                              height: 55,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(300),
                                onTap: ()  {
                                  Navigator.of(context).pushNamed('/Profile');
                                },
                                child: CircleAvatar(
                                  backgroundImage: NetworkImage(currentUser.value.image!.thumb),
                                ),
                              )),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [BoxShadow(color: Theme.of(context).hintColor.withOpacity(0.15), offset: Offset(0, 3), blurRadius: 10)],
                      ),
                      child: ListView(
                        shrinkWrap: true,
                        primary: false,
                        children: <Widget>[
                          ListTile(
                            leading: Icon(Icons.person),
                            title: Text(
                              S.of(context).profile_settings,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            trailing: ButtonTheme(
                              padding: EdgeInsets.all(0),
                              minWidth: 50.0,
                              height: 25.0,
                              child: ProfileSettingsDialog(
                                user: currentUser.value,
                                onChanged: () async{
                                  await _con.update(currentUser.value);
                                  if (currentUser.value.verifiedPhone) {
                                    return;
                                  }
                                  var bottomSheetController = _con.scaffoldKey.currentState?.showBottomSheet(

                                    (context) => MobileVerificationBottomSheetWidget(scaffoldKey: _con.scaffoldKey, user: currentUser.value),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: new BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
                                    ),
                                  );
                                  bottomSheetController?.closed.then((value) {
                                    _con.update(currentUser.value);
                                  });
                                  //setState(() {});
                                },
                              ),
                            ),
                          ),
                          ListTile(
                            onTap: () {},
                            dense: true,
                            title: Text(
                              S.of(context).full_name,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            trailing: Text(
                              currentUser.value.name!,
                              style: TextStyle(color: Theme.of(context).focusColor),
                            ),
                          ),
                          ListTile(
                            onTap: () {},
                            dense: true,
                            title: Text(
                              S.of(context).email,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            trailing: Text(
                              currentUser.value.email!,
                              style: TextStyle(color: Theme.of(context).focusColor),
                            ),
                          ),
                          ListTile(
                            onTap: () {},
                            dense: true,
                            title: Wrap(
                              spacing: 8,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Text(
                                  S.of(context).phone,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                if (currentUser.value.verifiedPhone ?? false)
                                  Icon(
                                    Icons.check_circle_outline,
                                    color: Theme.of(context).colorScheme.secondary,
                                    size: 22,
                                  )
                              ],
                            ),
                            trailing: Text(
                              currentUser.value.phone ?? "",
                              style: TextStyle(color: Theme.of(context).focusColor),
                            ),
                          ),
                          ListTile(
                            onTap: () {},
                            dense: true,
                            title: Text(
                              S.of(context).address,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            trailing: Text(
                              Helper.limitString(currentUser.value.address ?? S.of(context).unknown),
                              overflow: TextOverflow.fade,
                              softWrap: false,
                              style: TextStyle(color: Theme.of(context).focusColor),
                            ),
                          ),
                          ListTile(
                            onTap: () {},
                            dense: true,
                            title: Text(
                              S.of(context).about,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            trailing: Text(
                              Helper.limitString(currentUser.value.bio!),
                              overflow: TextOverflow.fade,
                              softWrap: false,
                              style: TextStyle(color: Theme.of(context).focusColor),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [BoxShadow(color: Theme.of(context).hintColor.withOpacity(0.15), offset: Offset(0, 3), blurRadius: 10)],
                      ),
                      child: ListView(
                        shrinkWrap: true,
                        primary: false,
                        children: <Widget>[
                          ListTile(
                            leading: Icon(Icons.credit_card),
                            title: Text(
                              S.of(context).payments_settings,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            trailing: ButtonTheme(
                              padding: EdgeInsets.all(0),
                              minWidth: 50.0,
                              height: 25.0,
                              child: PaymentSettingsDialog(
                                creditCard: _con.creditCard,
                                onChanged: () {
                                  _con.updateCreditCard(_con.creditCard);
                                  setState(() {});
                                },
                              ),
                            ),
                          ),
                          ListTile(
                            dense: true,
                            title: Text(
                              S.of(context).default_credit_card,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            trailing: Text(
                              _con.creditCard.number.isNotEmpty ? _con.creditCard.number.replaceRange(0, _con.creditCard.number.length - 4, '...') : '',
                              style: TextStyle(color: Theme.of(context).focusColor),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [BoxShadow(color: Theme.of(context).hintColor.withOpacity(0.15), offset: Offset(0, 3), blurRadius: 10)],
                      ),
                      child: ListView(
                        shrinkWrap: true,
                        primary: false,
                        children: <Widget>[
                          ListTile(
                            leading: Icon(Icons.settings),
                            title: Text(
                              S.of(context).app_settings,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ),
                          // ListTile(
                          //   onTap: () {
                          //     Navigator.of(context).pushNamed('/Languages');
                          //   },
                          //   dense: true,
                          //   title: Row(
                          //     children: <Widget>[
                          //       Icon(
                          //         Icons.translate,
                          //         size: 22,
                          //         color: Theme.of(context).focusColor,
                          //       ),
                          //       SizedBox(width: 10),
                          //       Text(
                          //         S.of(context).languages,
                          //         style: Theme.of(context).textTheme.bodyMedium,
                          //       ),
                          //     ],
                          //   ),
                          //   trailing: Text(
                          //     S.of(context).english,
                          //     style: TextStyle(color: Theme.of(context).focusColor),
                          //   ),
                          // ),
                          ListTile(
                            onTap: () {
                              Navigator.of(context).pushNamed('/DeliveryAddresses', arguments: false);
                            },
                            dense: true,
                            title: Row(
                              children: <Widget>[
                                Icon(
                                  Icons.place,
                                  size: 22,
                                  color: Theme.of(context).focusColor,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  S.of(context).delivery_addresses,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                          ListTile(
                            onTap: () {
                              Navigator.of(context).pushNamed('/Help');
                            },
                            dense: true,
                            title: Row(
                              children: <Widget>[
                                Icon(
                                  Icons.help,
                                  size: 22,
                                  color: Theme.of(context).focusColor,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  S.of(context).help_support,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ));
  }
}
