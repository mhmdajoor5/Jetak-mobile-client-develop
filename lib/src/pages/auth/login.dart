import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'dart:io' show Platform;

import '../../../generated/l10n.dart';
import '../../controllers/user_controller.dart';
import '../../helpers/helper.dart';
import '../../repository/user_repository.dart' as userRepo;

class LoginWidget extends StatefulWidget {
  @override
  _LoginWidgetState createState() => _LoginWidgetState();
}

class _LoginWidgetState extends StateMVC<LoginWidget> {
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _con.scaffoldKey,
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Form(
            key: _con.loginFormKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // الصورة في الأعلى
                Image.asset('assets/img/logo.png', height: 120),
                SizedBox(height: 40),

                // حقل الإيميل
                TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  onSaved: (input) {
                    if (input != null) _con.user.email = input;
                  },
                  validator: (input) {
                    if (input != null && !input.contains('@')) {
                      return S.of(context).should_be_a_valid_email;
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: S.of(context).email,
                    labelStyle: TextStyle(color: Theme.of(context).colorScheme.secondary),
                    contentPadding: EdgeInsets.all(12),
                    hintText: 'johndoe@gmail.com',
                    hintStyle: TextStyle(color: Theme.of(context).focusColor.withOpacity(0.7)),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.2)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.5)),
                    ),
                    prefixIcon: Icon(Icons.alternate_email, color: Theme.of(context).colorScheme.secondary),
                  ),
                ),
                SizedBox(height: 20),

                // حقل الباسورد
                TextFormField(
                  keyboardType: TextInputType.text,
                  onSaved: (input) {
                    if (input != null) _con.user.password = input;
                  },
                  validator: (input) {
                    if (input != null && input.length < 3) {
                      return S.of(context).should_be_more_than_3_characters;
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
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.2)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.5)),
                    ),
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
                  ),
                ),
                SizedBox(height: 40),

                // زر تسجيل الدخول
                SizedBox(
                  width: 200,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_con.loginFormKey.currentState!.validate()) {
                        _con.loginFormKey.currentState?.save();
                        _con.login();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      S.of(context).login,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),

                SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacementNamed('/Pages', arguments: 2);
                  },
                  child: Text(S.of(context).skip),
                ),

                TextButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacementNamed('/ForgetPassword');
                  },
                  child: Text(S.of(context).i_forgot_password,
                    style: TextStyle(color: Colors.black87),),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacementNamed('/SignUp');
                  },
                  child: Text(S.of(context).i_dont_have_an_account,
                    style: TextStyle(color: Colors.black87),),
                ),

                SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: SvgPicture.asset('assets/img/google_svg_icon.svg', height: 24, width: 24),
                      onPressed: () => _con.loginWithGoogle(),
                    ),
                    // if (!Platform.isIOS) ...[
                    //   SizedBox(width: 24),
                    //   IconButton(
                    //     icon: SvgPicture.asset('assets/img/facebook_svg_icon.svg', height: 24, width: 24),
                    //     onPressed: () => _con.loginWithFacebook(),
                    //   ),
                    //   SizedBox(width: 24),
                    //   IconButton(
                    //     icon: SvgPicture.asset('assets/img/apple_icon.svg', height: 24, width: 24),
                    //     onPressed: () {},
                    //   ),
                    // ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
