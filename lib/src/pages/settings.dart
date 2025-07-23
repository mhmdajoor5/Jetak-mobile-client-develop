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
import 'RecentOrdersWidget.dart';

class SettingsWidget extends StatefulWidget {
  @override
  _SettingsWidgetState createState() => _SettingsWidgetState();
}

class _SettingsWidgetState extends StateMVC<SettingsWidget> {
  final GlobalKey<FormState> _addressFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _nameFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _emailFormKey = GlobalKey<FormState>();
  late SettingsController _con;
  bool isEditingName = false;
  bool isEditingEmail = false;
  bool isEditingAddress = false;
  late TextEditingController fullNameController;
  late TextEditingController emailController;
  late TextEditingController addressController;

  bool _controllersInitialized = false;
  _SettingsWidgetState() : super(SettingsController()) {
    _con = controller as SettingsController;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_controllersInitialized && currentUser.value.id != null) {
      fullNameController = TextEditingController(text: currentUser.value.name ?? '');
      emailController = TextEditingController(text: currentUser.value.email ?? '');
      addressController = TextEditingController(text: currentUser.value.address ?? '');
      _controllersInitialized = true;
    }
  }

  @override
  void initState() {
    super.initState();
    if (currentUser.value.id != null) {
      fullNameController = TextEditingController(text: currentUser.value.name ?? '');
      emailController = TextEditingController(text: currentUser.value.email ?? '');
      addressController = TextEditingController(text: currentUser.value.address ?? '');
    } else {
      fullNameController = TextEditingController();
      emailController = TextEditingController();
      addressController = TextEditingController();
    }
  }

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    addressController.dispose();
    super.dispose();
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
                        currentUser.value.name ?? '',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        currentUser.value.email ?? '',
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
                        (currentUser.value.image != null && (currentUser.value.image!.thumb.isNotEmpty))
                          ? NetworkImage(currentUser.value.image!.thumb)
                          : AssetImage('assets/img/default_avatar.png') as ImageProvider, // Ensure this file exists in assets/img
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
            // trailing: ProfileSettingsDialog(
            //   user: currentUser.value,
            //   onChanged: () async {
            //     await _con.update(currentUser.value);
            //     if (!currentUser.value.verifiedPhone!) {
            //       // var bs = _con.scaffoldKey.currentState?.showBottomSheet(
            //       //       (ctx) => MobileVerificationBottomSheetWidget(
            //       //       scaffoldKey: _con.scaffoldKey,
            //       //       user: currentUser.value),
            //       //   shape: RoundedRectangleBorder(
            //       //       borderRadius: BorderRadius.vertical(top: Radius.circular(10))),
            //       // );
            //       // bs?.closed.then((_) => _con.update(currentUser.value));
            //     }
            //   },
            // ),
          ),
          Divider(height: 1),
          ListTile(
            dense: true,
            title: Text(
              S.of(context).full_name,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            trailing: isEditingName
                ? SizedBox(
              width: 200,
              child: Form(
                key: _nameFormKey,
                child: TextFormField(
                  controller: fullNameController,
                  autofocus: true,
                  style: TextStyle(color: Theme.of(context).hintColor),
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    hintText: S.of(context).john_doe,
                    labelText: S.of(context).full_name,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade400),
                    ),
                  ),
                  validator: (input) {
                    if (input == null || input.trim().length < 3) {
                      return S.of(context).not_a_valid_full_name;
                    }
                    return null;
                  },
                  onFieldSubmitted: (value) {
                    if (_nameFormKey.currentState!.validate()) {
                      setState(() {
                        isEditingName = false;
                        currentUser.value.name = value.trim();
                        _con.update(currentUser.value);
                      });
                    }
                  },
                  onEditingComplete: () {
                    if (_nameFormKey.currentState!.validate()) {
                      setState(() {
                        isEditingName = false;
                        currentUser.value.name = fullNameController.text.trim();
                        _con.update(currentUser.value);
                      });
                    }
                  },
                ),
              ),
            )
                : InkWell(
              onTap: () {
                setState(() {
                  isEditingName = true;
                });
              },
              child: Text(
                fullNameController.text,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          Divider(height: 1),
          ListTile(
            dense: true,
            title: Text(
              S.of(context).email,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            trailing: isEditingEmail
                ? SizedBox(
              width: 250,
              child: Form(
                key: _emailFormKey,
                child: TextFormField(
                  controller: emailController,
                  autofocus: true,
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(color: Theme.of(context).hintColor),
                  decoration: InputDecoration(
                    hintText: 'johndo@gmail.com',
                    labelText: S.of(context).email_address,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade400),
                    ),
                  ),
                  validator: (input) {
                    if (input == null || !input.contains('@') || input.trim().isEmpty) {
                      return S.of(context).not_a_valid_email;
                    }
                    return null;
                  },
                  onFieldSubmitted: (value) {
                    if (_emailFormKey.currentState!.validate()) {
                      setState(() {
                        isEditingEmail = false;
                        currentUser.value.email = value.trim();
                        _con.update(currentUser.value);
                      });
                    }
                  },
                  onEditingComplete: () {
                    if (_emailFormKey.currentState!.validate()) {
                      setState(() {
                        isEditingEmail = false;
                        currentUser.value.email = emailController.text.trim();
                        _con.update(currentUser.value);
                      });
                    }
                  },
                ),
              ),
            )
                : InkWell(
              onTap: () {
                setState(() {
                  isEditingEmail = true;
                });
              },
              child: Text(
                Helper.limitString(currentUser.value.email ?? ''),
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
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

          Divider(height: 1),

          ListTile(
            dense: true,
            title: Text(
              S.of(context).address,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            trailing: isEditingAddress
                ? SizedBox(
              width: 200,
              child: Form(
                key: _addressFormKey,
                child: TextFormField(
                  controller: addressController,
                  style: TextStyle(color: Theme.of(context).hintColor),
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    hintText: S.of(context).your_address,
                    labelText: S.of(context).address,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade400),
                    ),
                  ),
                  validator: (input) =>
                  input == null || input.trim().length < 3 ? S.of(context).not_a_valid_address : null,
                  autofocus: true,
                  onFieldSubmitted: (value) {
                    if (_addressFormKey.currentState?.validate() ?? false) {
                      setState(() {
                        isEditingAddress = false;
                        currentUser.value.address = addressController.text.trim();
                      });
                      _con.update(currentUser.value);
                    }
                  },
                  onEditingComplete: () {
                    if (_addressFormKey.currentState?.validate() ?? false) {
                      setState(() {
                        isEditingAddress = false;
                        currentUser.value.address = addressController.text.trim();
                      });
                      _con.update(currentUser.value);
                    }
                  },
                ),
              ),
            )
                : InkWell(
              onTap: () {
                setState(() {
                  isEditingAddress = true;
                });
              },
              child: Text(
                Helper.limitString(currentUser.value.address ?? ''),
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
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

          InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => RecentOrdersWidget(fromProfile: true),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  Icon(Icons.history),
                  SizedBox(width: 12),
                  Text(S.of(context).recent_orders,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
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
