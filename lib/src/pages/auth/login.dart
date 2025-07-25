import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'dart:io' show Platform;

import '../../../generated/l10n.dart';
import '../../controllers/user_controller.dart';
import '../../elements/BlockButtonWidget.dart';
import '../../helpers/app_config.dart' as config;
import '../../helpers/helper.dart';
import '../../repository/user_repository.dart' as userRepo;

class LoginWidget extends StatefulWidget {
  @override
  _LoginWidgetState createState() => _LoginWidgetState();
}

class _LoginWidgetState extends StateMVC<LoginWidget> {
  // final GoogleSignIn googleSignIn = GoogleSignIn(
  //   clientId: '263784919474-1puhiq82690jqq2dn5354veeprjpclkh.apps.googleusercontent.com', // ← ضع هنا الـ Client ID الصحيح من Google Console
  // );
  late UserController _con;

  _LoginWidgetState() : super(UserController()) {
    _con = controller as UserController;
  }
  @override
  void initState() {
    super.initState();
    getDeviceToken();
    if (userRepo.currentUser.value?.apiToken != null) {
      Navigator.of(context).pushReplacementNamed('/Pages', arguments: 2);
    }
  }

  void getDeviceToken() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    String? token = await messaging.getToken();
    print('Device Token: $token');

    // if (token != null) {
    //   final snackBar = SnackBar(content: Text("Device Token: $token"));
    //   ScaffoldMessenger.of(context).showSnackBar(snackBar);
    // }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: Helper.of(context).onWillPop,
      child: Scaffold(
        key: _con.scaffoldKey,
        resizeToAvoidBottomInset: false,
        body: Stack(
          alignment: AlignmentDirectional.topCenter,
          children: <Widget>[
            Positioned(
              top: 0,
              child: Container(
                width: config.App(context).appWidth(100),
                height: config.App(context).appHeight(37),
                decoration: BoxDecoration(color: Theme.of(context).colorScheme.secondary),
              ),
            ),
            Positioned(
              top: config.App(context).appHeight(37) - 120,
              child: Container(
                width: config.App(context).appWidth(84),
                height: config.App(context).appHeight(37),
                child: Text(
                  S.of(context).lets_start_with_login,
                  style: Theme.of(context).textTheme.displayMedium?.merge(TextStyle(color: Theme.of(context).primaryColor)),
                ),
              ),
            ),
            Positioned(
              top: config.App(context).appHeight(37) - 50,
              child: Container(
                decoration: BoxDecoration(color: Theme.of(context).primaryColor, borderRadius: BorderRadius.all(Radius.circular(10)), boxShadow: [
                  BoxShadow(
                    blurRadius: 50,
                    color: Theme.of(context).hintColor.withOpacity(0.2),
                  )
                ]),
                margin: EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                padding: EdgeInsets.only(top: 50, right: 27, left: 27, bottom: 20),
                width: config.App(context).appWidth(88),
//              height: config.App(context).appHeight(55),
                child: Form(
                  key: _con.loginFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      TextFormField(
                        keyboardType: TextInputType.emailAddress,
                        onSaved: (input) {
                          if (input != null){
                            _con.user.email = input;
                          }
                        },
                        validator: (input) {
                          if (input != null){
                            return !input.contains('@') ? S.of(context).should_be_a_valid_email : null;
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: S.of(context).email,
                          labelStyle: TextStyle(color: Theme.of(context).colorScheme.secondary),
                          contentPadding: EdgeInsets.all(12),
                          hintText: 'johndoe@gmail.com',
                          hintStyle: TextStyle(color: Theme.of(context).focusColor.withOpacity(0.7)),
                          prefixIcon: Icon(Icons.alternate_email, color: Theme.of(context).colorScheme.secondary),
                          border: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.2))),
                          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.5))),
                          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.2))),
                        ),
                      ),
                      SizedBox(height: 30),
                      TextFormField(
                        keyboardType: TextInputType.text,
                        onSaved: (input) {
                          if (input != null){
                            _con.user.password = input;
                          }
                        },
                        validator: (input) {
                          if (input != null){
                            return input.length < 3 ? S.of(context).should_be_more_than_3_characters : null;
                          }
                          return null;
                        },
                        obscureText: _con.hidePassword,
                        decoration: InputDecoration(
                          labelText: S.of(context).password,
                          labelStyle: TextStyle(color: Theme.of(context).colorScheme.secondary),
                          contentPadding: EdgeInsets.all(12),
                          hintText: '••••••••••••',
                          hintStyle: TextStyle(color: Theme.of(context).focusColor.withOpacity(0.7)),
                          prefixIcon: Icon(Icons.lock_outline, color: Theme.of(context).colorScheme.secondary),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _con.hidePassword = !_con.hidePassword;
                              });
                            },
                            color: Theme.of(context).focusColor,
                            icon: Icon(_con.hidePassword ? Icons.visibility : Icons.visibility_off),
                          ),
                          border: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.2))),
                          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.5))),
                          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.2))),
                        ),
                      ),
                      SizedBox(height: 30),
                      BlockButtonWidget(
                        text: Text(
                          S.of(context).login,
                          style: TextStyle(color: Theme.of(context).primaryColor),
                        ),
                        color: Theme.of(context).colorScheme.secondary,
                        onPressed: () {
                          _con.login();
                        },
                      ),
                      SizedBox(height: 15),
                      MaterialButton(
                        elevation: 0,
                        focusElevation: 0,
                        highlightElevation: 0,
                        onPressed: () {
                          Navigator.of(context).pushReplacementNamed('/Pages', arguments: 2);
                        },
                        shape: StadiumBorder(),
                        textColor: Theme.of(context).hintColor,
                        child: Text(S.of(context).skip),
                        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: SvgPicture.asset('assets/img/google_svg_icon.svg', height: 20, width: 20),
                            iconSize: 10,
                            onPressed: () => _con.loginWithGoogle(),
                          ),
                          if (!Platform.isIOS) ...[
                            SizedBox(width: 20),
                            IconButton(
                              icon: SvgPicture.asset('assets/img/facebook_svg_icon.svg', height: 20, width: 20),
                              iconSize: 10,
                              onPressed: () => _con.loginWithFacebook(),
                            ),
                            SizedBox(width: 20),
                            IconButton(
                              icon: SvgPicture.asset('assets/img/apple_icon.svg', height: 20, width: 20),
                              iconSize: 10,
                              onPressed: () {},
                            ),
                          ],
                        ],
                      ),

//                      SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 10,
              child: Column(
                children: <Widget>[
                  MaterialButton(
                    elevation: 0,
                    focusElevation: 0,
                    highlightElevation: 0,
                    onPressed: () {
                      Navigator.of(context).pushReplacementNamed('/ForgetPassword');
                    },
                    textColor: Theme.of(context).hintColor,
                    child: Text(S.of(context).i_forgot_password),
                  ),
                  MaterialButton(
                    elevation: 0,
                    focusElevation: 0,
                    highlightElevation: 0,
                    onPressed: () {
                      Navigator.of(context).pushReplacementNamed('/SignUp');
                    },
                    textColor: Theme.of(context).hintColor,
                    child: Text(S.of(context).i_dont_have_an_account),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
