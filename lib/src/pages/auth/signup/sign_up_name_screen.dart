import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../../../generated/l10n.dart';
import '../../../controllers/user_controller.dart';

class SignUpNameScreen extends StatefulWidget {
  @override
  _SignUpNameScreenState createState() => _SignUpNameScreenState();
}

class _SignUpNameScreenState extends StateMVC<SignUpNameScreen> {
  late UserController _con;
  String firstName = '';
  String lastName = '';

  _SignUpNameScreenState() : super(UserController()) {
    _con = controller as UserController;
  }

  @override
  Widget build(BuildContext context) {
    print('First name: $firstName');
    print('Last name: $lastName');
    print('UserController name: ${_con.user.firstName} ${_con.user.lastName}');

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
                Image.asset('assets/img/logo.png', height: 120),
                SizedBox(height: 40),
                TextFormField(
                  keyboardType: TextInputType.text,
                  onChanged: (val) => firstName = val,
                  onSaved: (input) {
                    if (input != null) firstName = input;
                  },
                  validator: (input) {
                    if (input != null && input.length < 3)
                      return S.of(context).should_be_more_than_3_letters;
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'First Name',
                    labelStyle: TextStyle(color: Theme.of(context).colorScheme.secondary),
                    contentPadding: EdgeInsets.all(12),
                    hintText: S.of(context).john_doe,
                    hintStyle: TextStyle(color: Theme.of(context).focusColor.withOpacity(0.7)),
                    border: OutlineInputBorder(
                        borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.2))),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.5))),
                  ),
                ),
                SizedBox(height: 20),
                TextFormField(
                  keyboardType: TextInputType.text,
                  onChanged: (val) => lastName = val,
                  onSaved: (input) {
                    if (input != null) lastName = input;
                  },
                  validator: (input) {
                    if (input != null && input.length < 3)
                      return S.of(context).should_be_more_than_3_letters;
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Last Name',
                    labelStyle: TextStyle(color: Theme.of(context).colorScheme.secondary),
                    contentPadding: EdgeInsets.all(12),
                    hintStyle: TextStyle(color: Theme.of(context).focusColor.withOpacity(0.7)),
                    border: OutlineInputBorder(
                        borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.2))),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.5))),
                  ),
                ),
                SizedBox(height: 40),
                SizedBox(
                  width: 200,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {
                      if (_con.loginFormKey.currentState!.validate()) {
                        _con.loginFormKey.currentState?.save();
                        _con.user.name = '$firstName $lastName';
                        Navigator.of(context).pushNamed(
                          '/SignUpEmailPassword',
                          arguments: {
                            'firstName': firstName,
                            'lastName': lastName,
                          },
                        );

                      }
                    },
                    child: Text('Continue', style: TextStyle(color: Colors.white)),
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
