import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../../../generated/l10n.dart';
import '../../../controllers/user_controller.dart';
import '../../../elements/BlockButtonWidget.dart';
import '../../../helpers/phone_util.dart';
import 'SignUpVerificationScreen.dart';

class SignUpPhoneNumberScreen extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String email;
  final String password;

  const SignUpPhoneNumberScreen({
    Key? key,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
  }) : super(key: key);

  @override
  _SignUpPhoneNumberScreenState createState() => _SignUpPhoneNumberScreenState();
}

class _SignUpPhoneNumberScreenState extends StateMVC<SignUpPhoneNumberScreen> {
  late UserController _con;

  _SignUpPhoneNumberScreenState() : super(UserController()) {
    _con = controller as UserController;
  }

  @override
  void initState() {
    super.initState();
    // خزّن البيانات الممررة في الـ controller
    _con.user.firstName = widget.firstName;
    _con.user.lastName = widget.lastName;
    _con.user.name = '${widget.firstName} ${widget.lastName}';
    _con.user.email = widget.email;
    _con.user.password = widget.password;
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
              children: [
                Image.asset('assets/img/logo.png', height: 120),
                SizedBox(height: 40),
                TextFormField(
                  keyboardType: TextInputType.phone,
                  onSaved: (input) {
                    if (input != null) {
                      _con.user.phone = input;
                    }
                  },
                  validator: (input) {
                    if (input != null) return validatePhoneNumber(input);
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: S.of(context).phoneNumber,
                    labelStyle: TextStyle(color: Theme.of(context).colorScheme.secondary),
                    contentPadding: EdgeInsets.all(12),
                    hintText: '+91 1362 699765',
                    hintStyle: TextStyle(color: Theme.of(context).focusColor.withOpacity(0.7)),
                    prefixIcon: Icon(Icons.phone_android, color: Theme.of(context).colorScheme.secondary),
                    border: OutlineInputBorder(
                        borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.2))),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.5))),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.2))),
                  ),
                ),
                SizedBox(height: 40),
                BlockButtonWidget(
                  text: Text(
                    S.of(context).register,
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                  color: Theme.of(context).colorScheme.secondary,
                  // onPressed: () async {
                  //   if (_con.loginFormKey.currentState!.validate()) {
                  //     _con.loginFormKey.currentState?.save();
                  //
                  //     if (_con.user.phone == null || _con.user.phone!.isEmpty) {
                  //       ScaffoldMessenger.of(context).showSnackBar(
                  //         SnackBar(content: Text('يرجى إدخال رقم الهاتف')),
                  //       );
                  //       return;
                  //     }
                  //     await FirebaseAuth.instance.verifyPhoneNumber(
                  //       phoneNumber: _con.user.phone!,
                  //       timeout: const Duration(seconds: 60),
                  //
                  //       verificationCompleted: (PhoneAuthCredential credential) async {
                  //         await FirebaseAuth.instance.signInWithCredential(credential);
                  //       },
                  //
                  //       verificationFailed: (FirebaseAuthException e) {
                  //         ScaffoldMessenger.of(context).showSnackBar(
                  //           SnackBar(content: Text('فشل التحقق: ${e.message}')),
                  //         );
                  //       },
                  //
                  //       codeSent: (String verificationId, int? resendToken) {
                  //         Navigator.of(context).pushReplacement(
                  //           MaterialPageRoute(
                  //             builder: (context) => SignUpVerificationScreen(
                  //               verificationId: verificationId,
                  //               phoneNumber: _con.user.phone!,
                  //             ),
                  //           ),
                  //         );
                  //       },
                  //
                  //       codeAutoRetrievalTimeout: (String verificationId) {
                  //       },
                  //     );
                  //   }
                  // },
                  onPressed: () async {
                    if (_con.loginFormKey.currentState!.validate()) {
                      _con.loginFormKey.currentState?.save();

                      if (_con.user.phone == null || _con.user.phone!.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('يرجى إدخال رقم الهاتف')),
                        );
                        return;
                      }

                      await _con.register();

                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => SignUpVerificationScreen(
                            verificationId: 'dummy-verification-id',
                            phoneNumber: _con.user.phone!,
                          ),
                        ),
                      );
                    }
                  },

                ),
                SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed('/Login');
                  },
                  child: Text(
                    S.of(context).i_have_account_back_to_login,
                    style: TextStyle(color: Theme.of(context).hintColor),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
