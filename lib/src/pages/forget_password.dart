import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../controllers/user_controller.dart';

class ForgetPasswordWidget extends StatefulWidget {
  @override
  _ForgetPasswordWidgetState createState() => _ForgetPasswordWidgetState();
}

class _ForgetPasswordWidgetState extends StateMVC<ForgetPasswordWidget> {
  late UserController _con;

  _ForgetPasswordWidgetState() : super(UserController()) {
    _con = controller as UserController;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _con.scaffoldKey,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Form(
              key: _con.loginFormKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Image.asset('assets/img/login.jpg', height: 180),
                  Text('${S.of(context).forgot_passwordd}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Theme.of(context).colorScheme.secondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 40),

                  TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    onSaved: (input) {
                      if (input != null) {
                        _con.user.email = input;
                      }
                    },
                    validator: (input) {
                      if (input != null) {
                        return !input.contains('@')
                            ? S.of(context).should_be_a_valid_email
                            : null;
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: S.of(context).email,
                      labelStyle: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      contentPadding: EdgeInsets.all(12),
                      hintText: 'johndoe@gmail.com',
                      hintStyle: TextStyle(
                        color: Theme.of(context).focusColor.withOpacity(0.7),
                      ),
                      prefixIcon: Icon(
                        Icons.alternate_email,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Theme.of(context).focusColor.withOpacity(0.2),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Theme.of(context).focusColor.withOpacity(0.5),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Theme.of(context).focusColor.withOpacity(0.2),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 40),
                  SizedBox(
                    width: 200,
                    child: ElevatedButton(
                      onPressed: () {
                        _con.resetPassword();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        S.of(context).send_password_reset_link,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),

                  SizedBox(height: 150),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacementNamed('/Login');
                    },
                    child: Text(
                      S.of(context).i_remember_my_password_return_to_login,
                      style: TextStyle(color: Colors.black87),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacementNamed('/SignUp');
                    },
                    child: Text(S.of(context).i_dont_have_an_account,
                      style: TextStyle(color: Colors.black87),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
