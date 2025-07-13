import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../../../generated/l10n.dart';
import '../../../controllers/user_controller.dart';

class SignUpVerificationScreen extends StatefulWidget {
  final String verificationId;
  final String phoneNumber;

  const SignUpVerificationScreen({
    Key? key,
    required this.verificationId,
    required this.phoneNumber,
  }) : super(key: key);

  @override
  _SignUpVerificationScreenState createState() => _SignUpVerificationScreenState();
}

class _SignUpVerificationScreenState extends StateMVC<SignUpVerificationScreen> {
  final int codeLength = 4;
  late List<TextEditingController> controllers;
  late List<FocusNode> focusNodes;
  int resendCooldown = 30;
  bool canResend = false;
  Timer? _resendTimer;

  bool isVerifying = false;
  String errorMessage = '';

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

  void resendCode() async {
    setState(() {
      isVerifying = true;
      errorMessage = '';
    });

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: widget.phoneNumber,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) {
      },
      verificationFailed: (FirebaseAuthException e) {
        setState(() {
          errorMessage = e.message ?? 'فشل إرسال الكود';
          isVerifying = false;
        });
      },
      codeSent: (String newVerificationId, int? resendToken) {
        setState(() {
          isVerifying = false;
        });

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => SignUpVerificationScreen(
              verificationId: newVerificationId,
              phoneNumber: widget.phoneNumber,
            ),
          ),
        );
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        startResendCooldown();
      },
    );
  }


  @override
  void initState() {
    super.initState();
    controllers = List.generate(codeLength, (_) => TextEditingController());
    focusNodes = List.generate(codeLength, (_) => FocusNode());
    startResendCooldown();
  }

  @override
  void dispose() {
    for (var c in controllers) c.dispose();
    for (var f in focusNodes) f.dispose();
    super.dispose();
  }

  void verifyOTP() async {
    String smsCode = controllers.map((c) => c.text).join();
    if (smsCode.length < codeLength) return;

    setState(() {
      isVerifying = true;
      errorMessage = '';
    });

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: smsCode,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم التحقق بنجاح 🎉'),
          backgroundColor: Colors.green,
        ),
      );

      await Future.delayed(Duration(seconds: 2));
      Navigator.of(context).pushReplacementNamed('/Pages', arguments: 2);

    } catch (e) {
      setState(() {
        //errorMessage = S.of(context).invalidCodeTryAgain;
        isVerifying = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    bool isRTL = ['ar', 'he'].contains(locale.languageCode);

    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).verifyCode),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Directionality(
          textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                S.of(context).enterThe4DigitCodeSentTo.replaceFirst(
                  '{phone}',
                  widget.phoneNumber,
                ),
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
                        if (value.isNotEmpty && index < codeLength - 1) {
                          FocusScope.of(context).requestFocus(focusNodes[index + 1]);
                        } else if (value.isEmpty && index > 0) {
                          FocusScope.of(context).requestFocus(focusNodes[index - 1]);
                        }
                      },
                    ),
                  );
                }),
              ),
              if (errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Text(
                    errorMessage,
                    style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.bold),
                  ),
                ),
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
                    S.of(context).verifyCode,
                    style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Column(
                children: [
                  TextButton(
                    onPressed: canResend ? resendCode : null,
                    child: Text(
                      S.of(context).didntReceiveTheCodeResendit,
                      style: TextStyle(
                        color: canResend ? Colors.blue.shade700 : Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (!canResend)
                    Text(
                      'إعادة الإرسال خلال $resendCooldown ثانية',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
