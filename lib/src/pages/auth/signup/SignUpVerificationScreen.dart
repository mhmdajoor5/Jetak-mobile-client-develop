import 'dart:async';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart' as userModel;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../../generated/l10n.dart';
import '../../../repository/user_repository.dart' as userRepo;

class SignUpVerificationScreen extends StatefulWidget {
  final String phoneNumber;

  const SignUpVerificationScreen({
    Key? key,
    required this.phoneNumber,
  }) : super(key: key);

  @override
  _SignUpVerificationScreenState createState() => _SignUpVerificationScreenState();
}

class _SignUpVerificationScreenState extends State<SignUpVerificationScreen> {
  final int codeLength = 4;
  late List<TextEditingController> controllers;
  late List<FocusNode> focusNodes;
  int resendCooldown = 30;
  bool canResend = false;
  Timer? _resendTimer;

  bool isVerifying = false;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    controllers = List.generate(codeLength, (_) => TextEditingController());
    focusNodes = List.generate(codeLength, (_) => FocusNode());
    sendOtp();
    startResendCooldown();
  }

  Future<void> sendOtp() async {
    try {
      final response = await http.post(
        Uri.parse('https://carrytechnologies.co/api/send-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "api_token": "fXLu7VeYgXDu82SkMxlLPG1mCAXc4EBIx6O5isgYVIKFQiHah0xiOHmzNsBv",
          "phone": widget.phoneNumber,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true || data['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(S.of(context).otp_sent_success)),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(S.of(context).otp_sent_error)),
          );
        }
      }
    } catch (e) {
      print('Send OTP Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context).otp_send_error)),
      );
    }
  }

  void startResendCooldown() {
    setState(() {
      canResend = false;
      resendCooldown = 30;
    });

    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        resendCooldown--;
        if (resendCooldown <= 0) {
          canResend = true;
          _resendTimer?.cancel();
        }
      });
    });
  }

  void resendCode() {
    sendOtp();
    startResendCooldown();
  }

  void verifyOTP() async {
    String smsCode = controllers.map((c) => c.text).join();
    if (smsCode.length < codeLength) return;

    setState(() {
      isVerifying = true;
      errorMessage = '';
    });

    try {
      final response = await http.post(
        Uri.parse('https://carrytechnologies.co/api/submit-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "api_token": "fXLu7VeYgXDu82SkMxlLPG1mCAXc4EBIx6O5isgYVIKFQiHah0xiOHmzNsBv",
          "code": smsCode,
        }),
      );

      setState(() => isVerifying = false);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true || data['status'] == 'success') {
          print('OTP verified successfully');
          userRepo.currentUser.value.updatePhoneVerification(true);

          await userRepo.saveCurrentUser(json.encode(userRepo.currentUser.value.toMap()));

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(S.of(context).otp_verification_success)),
          );

          Navigator.of(context).pushReplacementNamed('/Pages', arguments: 0);

      } else {
          setState(() {
            errorMessage = S.of(context).otp_verification_invalid;
          });
        }
      } else {
        setState(() {
          errorMessage = "❌ ${S.of(context).verification_failed}: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        isVerifying = false;
        errorMessage = S.of(context).otp_verification_error;
      });
      print('OTP Verify Error: $e');
    }
  }


  @override
  void dispose() {
    for (var c in controllers) c.dispose();
    for (var f in focusNodes) f.dispose();
    _resendTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).verification_title),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              S.of(context).codeSent,
              //S.of(context).verification_instruction(widget.phoneNumber),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(codeLength, (index) {
                return SizedBox(
                  width: 55,
                  child: TextField(
                    controller: controllers[index],
                    focusNode: focusNodes[index],
                    maxLength: 1,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      counterText: '',
                      hintText: '0',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 20,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.blue.shade300, width: 2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.blue.shade700, width: 3),
                      ),
                    ),
                    onChanged: (value) {
                      if (value.length > 1) {
                        controllers[index].text = value.substring(0, 1);
                      }
                      if (value.isNotEmpty) {
                        if (index < codeLength - 1) {
                          FocusScope.of(context).requestFocus(focusNodes[index + 1]);
                        } else {
                          FocusScope.of(context).unfocus();
                        }
                      } else {
                        if (index > 0) {
                          FocusScope.of(context).requestFocus(focusNodes[index - 1]);
                          controllers[index - 1].selection = TextSelection.collapsed(offset: controllers[index - 1].text.length);
                        }
                      }

                      if (controllers.every((c) => c.text.isNotEmpty)) {
                        verifyOTP();
                      }
                    },
                  ),
                );
              }),
            ),
            // if (errorMessage.isNotEmpty)
            //   Padding(
            //     padding: const EdgeInsets.only(top: 20),
            //     child: Text(
            //       errorMessage,
            //       style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.bold),
            //     ),
            //   ),
            SizedBox(height: 30),
            SizedBox(
              width: 200,
              child: ElevatedButton(
                onPressed: isVerifying ? null : verifyOTP,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: isVerifying
                    ? SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                )
                    : Text(
                    S.of(context).verify,
                  style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SizedBox(height: 20),
            Column(
              children: [
                isVerifying
                    ? CircularProgressIndicator()
                    : TextButton(
                  onPressed: canResend ? resendCode : null,
                  child: Text(
                    S.of(context).resend_code,
                    style: TextStyle(
                      color: canResend ? Colors.blue.shade700 : Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (!canResend)
                  Text(
                  S.of(context).resend_available_in(resendCooldown),
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                    ),
                  ),
              ],
            ),
            SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                S.of(context).back_to_edit_number,
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
