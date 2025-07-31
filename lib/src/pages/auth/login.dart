import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../../generated/l10n.dart';
import '../../controllers/user_controller.dart';
import '../../helpers/helper.dart';
import '../../repository/user_repository.dart' as userRepo;

class LoginWidget extends StatefulWidget {
  @override
  _LoginWidgetState createState() => _LoginWidgetState();
}

class _LoginWidgetState extends StateMVC<LoginWidget> with SingleTickerProviderStateMixin {
  late UserController _con;
  double _scale = 1.0;

  _LoginWidgetState() : super(UserController()) {
    _con = controller as UserController;
  }

  @override
  void initState() {
    super.initState();
    getDeviceToken();

    if (userRepo.currentUser.value?.apiToken != null) {
      Navigator.of(context).pushReplacementNamed('/Pages', arguments: 0);
    }
  }

  void getDeviceToken() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    String? token = await messaging.getToken();
    print('Device Token: $token');
  }

  Widget _buildBusinessIcon(IconData icon, String label) {
    return Column(
      children: [
        Icon(
          icon, 
          size: 30, 
          color: Colors.blue[700],
        ),
        SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.black54,
            fontFamily: 'Cairo',
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
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
                Container(
                  padding: EdgeInsets.all(30),
                  child: Column(
                    children: [
                      Text(
                        S.of(context).hi,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          fontFamily: 'Cairo',
                        ),
                        textAlign: TextAlign.center,
                      ),
                      // App Logo with Business Theme
                      // Container(
                      //   padding: EdgeInsets.all(20),
                      //   decoration: BoxDecoration(
                      //     color: Theme.of(context).primaryColor.withOpacity(0.1),
                      //     borderRadius: BorderRadius.circular(20),
                      //     border: Border.all(
                      //       color: Theme.of(context).primaryColor.withOpacity(0.3),
                      //       width: 2,
                      //     ),
                      //   ),
                      //   child: Image.asset(
                      //     'assets/img/carry-eats-hub-logo.png',
                      //     height: 80,
                      //     width: 80,
                      //   ),
                      // ),
                      //
                      // SizedBox(height: 25),
                      //
                      // // Business Welcome Text
                      // Text(
                      //   S.of(context).login_welcome,
                      //   style: TextStyle(
                      //     fontSize: 28,
                      //     fontWeight: FontWeight.bold,
                      //     color: Colors.black87,
                      //     fontFamily: 'Cairo',
                      //   ),
                      //   textAlign: TextAlign.center,
                      // ),
                      //
                      // SizedBox(height: 10),
                      //
                      //
                      // SizedBox(height: 8),
                      //
                      // Text(
                      //   S.of(context).login_subtitle,
                      //   style: TextStyle(
                      //     fontSize: 14,
                      //     color: Colors.black45,
                      //     fontFamily: 'Cairo',
                      //   ),
                      //   textAlign: TextAlign.center,
                      // ),
                      //
                      // SizedBox(height: 20),
                      //
                      // // Business Icons Row
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      //   children: [
                      //     _buildBusinessIcon(Icons.restaurant, S.of(context).login_icon_restaurants),
                      //     _buildBusinessIcon(Icons.delivery_dining, S.of(context).login_icon_delivery),
                      //     _buildBusinessIcon(Icons.star, S.of(context).login_icon_quality),
                      //   ],
                      // ),
                    ],
                  ),
                ),
                SizedBox(height: 40),
                TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  onSaved: (input) => _con.user.email = input ?? '',
                  validator: (input) {
                    if (input != null && !input.contains('@')) {
                      return S.of(context).should_be_a_valid_email;
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: S.of(context).Enter_your_email,
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

                TextFormField(
                  keyboardType: TextInputType.text,
                  onSaved: (input) => _con.user.password = input ?? '',
                  validator: (input) {
                    if (input != null && input.length < 3) {
                      return S.of(context).should_be_more_than_3_characters;
                    }
                    return null;
                  },
                  obscureText: _con.hidePassword,
                  decoration: InputDecoration(
                    labelText: S.of(context).Enter_password,
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
                      icon: Icon(_con.hidePassword ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => _con.hidePassword = !_con.hidePassword),
                      color: Theme.of(context).focusColor,
                    ),
                  ),
                ),

                SizedBox(height: 40),

                SizedBox(
                  width: 200,
                  child: GestureDetector(
                    onTapDown: (_) => setState(() => _scale = 0.95),
                    onTapUp: (_) => setState(() => _scale = 1.0),
                    onTapCancel: () => setState(() => _scale = 1.0),
                    onTap: () {
                      if (_con.loginFormKey.currentState!.validate()) {
                        _con.loginFormKey.currentState?.save();
                        _con.login();
                      }
                    },
                    child: AnimatedScale(
                      scale: _scale,
                      duration: Duration(milliseconds: 100),
                      child: ElevatedButton(
                        onPressed: null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          disabledBackgroundColor: Colors.blue,
                          padding: EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text(
                          S.of(context).login,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),

                TextButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacementNamed('/Pages', arguments: 0);
                  },
                  child: Text(S.of(context).skip),
                ),

                TextButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacementNamed('/ForgetPassword');
                  },
                  child: Text(
                    S.of(context).forgot_password,
                    style: TextStyle(color: Colors.black87),
                  ),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      S.of(context).do_not_have_account,
                      style: TextStyle(color: Colors.black87),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 4),
                        minimumSize: Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () {
                        Navigator.of(context).pushReplacementNamed('/SignUp');
                      },
                      child: Text(
                        S.of(context).Sign,
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 20),

                //
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.center,
                //   children: [
                //     IconButton(
                //       icon: SvgPicture.asset('assets/img/google_svg_icon.svg', height: 24, width: 24),
                //       onPressed: () => _con.loginWithGoogle(),
                //     ),
                //     if (!Platform.isIOS) ...[
                //       SizedBox(width: 24),
                //       IconButton(
                //         icon: SvgPicture.asset('assets/img/facebook_svg_icon.svg', height: 24, width: 24),
                //         onPressed: () => _con.loginWithFacebook(),
                //       ),
                //       SizedBox(width: 24),
                //       IconButton(
                //         icon: SvgPicture.asset('assets/img/apple_icon.svg', height: 24, width: 24),
                //         onPressed: () {},
                //       ),
                //     ],
                //   ],
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  }