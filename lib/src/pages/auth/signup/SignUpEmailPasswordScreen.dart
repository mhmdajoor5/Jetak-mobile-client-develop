import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../../../generated/l10n.dart';
import '../../../controllers/user_controller.dart';

class SignUpEmailPasswordScreen extends StatefulWidget {
  final String firstName;
  final String lastName;

  const SignUpEmailPasswordScreen({
    Key? key,
    required this.firstName,
    required this.lastName,
  }) : super(key: key);

  @override
  _SignUpEmailPasswordScreenState createState() => _SignUpEmailPasswordScreenState();
}

class _SignUpEmailPasswordScreenState extends StateMVC<SignUpEmailPasswordScreen> {
  late UserController _con;
  String email = '';
  String password = '';

  _SignUpEmailPasswordScreenState() : super(UserController()) {
    _con = controller as UserController;
  }

  @override
  void initState() {
    super.initState();
    _con.user.name = '${widget.firstName} ${widget.lastName}';
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
                Text(
                  S.of(context).writeEmailAndPassword,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    fontFamily: 'Cairo',
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 40),
                TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  onSaved: (input) {
                    if (input != null) {
                      _con.user.email = input;
                      email = input;
                    }
                  },
                  validator: (input) {
                    if (input != null && !input.contains('@'))
                      return S.of(context).should_be_a_valid_email;
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: S.of(context).email,
                    labelStyle: TextStyle(color: Theme.of(context).colorScheme.secondary),
                    contentPadding: EdgeInsets.all(12),
                    hintText: 'johndoe@gmail.com',
                    hintStyle: TextStyle(color: Theme.of(context).focusColor.withOpacity(0.7)),
                    prefixIcon: Icon(Icons.alternate_email, color: Theme.of(context).colorScheme.secondary),
                    border: OutlineInputBorder(
                        borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.2))),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.5))),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.2))),
                  ),
                ),
                SizedBox(height: 20),
                TextFormField(
                  obscureText: _con.hidePassword,
                  onSaved: (input) {
                    if (input != null) {
                      _con.user.password = input;
                      password = input;
                    }
                  },
                  validator: (input) {
                    if (input != null && input.length < 6)
                      return S.of(context).should_be_more_than_6_letters;
                    return null;
                  },
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
                    border: OutlineInputBorder(
                        borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.2))),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.5))),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.2))),
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

                        print('firstName: ${widget.firstName}');
                        print('lastName: ${widget.lastName}');
                        print('email: $email');
                        print('password: $password');

                        Navigator.of(context).pushNamed(
                          '/SignUpPhoneNumber',
                          arguments: {
                            'firstName': widget.firstName,
                            'lastName': widget.lastName,
                            'email': _con.user.email ?? '',
                            'password': _con.user.password ?? '',
                          },
                        );
                      }
                    },
                    child: Text(S.of(context).continue_button, style: TextStyle(color: Colors.white)),
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
