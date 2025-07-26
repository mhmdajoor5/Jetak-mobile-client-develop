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
                Container(
                  padding: EdgeInsets.all(30),
                  child: Column(
                    children: [
                      // App Logo with Business Theme
                      Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Theme.of(context).primaryColor.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: Image.asset(
                          'assets/img/carry-eats-hub-logo.png',
                          height: 80,
                          width: 80,
                        ),
                      ),

                      SizedBox(height: 25),

                      // Business Welcome Text
                      Text(
                        'مرحباً بك في Jetak',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          fontFamily: 'Cairo',
                        ),
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(height: 10),


                      SizedBox(height: 8),

                      Text(
                        'اطلب من أفضل المطاعم واحصل على توصيل سريع',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black45,
                          fontFamily: 'Cairo',
                        ),
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(height: 20),

                      // Business Icons Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildBusinessIcon(Icons.restaurant, 'مطاعم'),
                          _buildBusinessIcon(Icons.delivery_dining, 'توصيل'),
                          _buildBusinessIcon(Icons.star, 'جودة'),
                        ],
                      ),
                    ],
                  ),
                ),
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
