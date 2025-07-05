import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../../generated/l10n.dart';
import '../helpers/app_config.dart' as config;
import '../models/user.dart' as userModel;
import '../repository/user_repository.dart';
import 'BlockButtonWidget.dart';

class MobileVerificationBottomSheetWidget extends StatefulWidget {
  final GlobalKey<ScaffoldState>? scaffoldKey;
  final userModel.User? user;
  final ValueChanged<bool>? valueChangedCallback;

  MobileVerificationBottomSheetWidget({Key? key, this.scaffoldKey, this.user, this.valueChangedCallback}) : super(key: key);

  @override
  _MobileVerificationBottomSheetWidgetState createState() => _MobileVerificationBottomSheetWidgetState();
}

class _MobileVerificationBottomSheetWidgetState extends State<MobileVerificationBottomSheetWidget> {
  final bool skipOTP = true; // ✅ تجاوز التحقق دائماً

  bool isLoading = false;
  String smsSent = '';
  String? errorMessage;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController textEditingController = TextEditingController();
  late StreamController<ErrorAnimationType> errorController;

  @override
  void initState() {
    errorController = StreamController<ErrorAnimationType>();
    super.initState();
    verifyPhone();
  }

  @override
  void dispose() {
    errorController.close();
    textEditingController.dispose();
    super.dispose();
  }

  Future<void> verifyPhone() async {
    currentUser.value.verificationId = '';
    smsSent = '';
    if (!skipOTP) {
      await sendOTP(currentUser.value.phone ?? '');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 500,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: const BorderRadius.only(topRight: Radius.circular(20), topLeft: Radius.circular(20)),
        boxShadow: [BoxShadow(color: Theme.of(context).focusColor.withOpacity(0.4), blurRadius: 30, offset: const Offset(0, -30))],
      ),
      child: Stack(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 25),
            child: ListView(
              padding: const EdgeInsets.only(top: 40, bottom: 15, left: 20, right: 20),
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Text(S.of(context).verifyPhoneNumber, style: Theme.of(context).textTheme.headlineMedium, textAlign: TextAlign.center),
                    const SizedBox(height: 10),
                    errorMessage == null
                        ? Text(S.of(context).weAreSendingOtpToValidateYourMobileNumberHang, style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center)
                        : Text(errorMessage!, style: Theme.of(context).textTheme.bodyMedium?.merge(const TextStyle(color: Colors.redAccent)), textAlign: TextAlign.center),
                  ],
                ),
                const SizedBox(height: 30),
                if (!skipOTP)
                  PinCodeTextField(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    appContext: context,
                    pastedTextStyle: TextStyle(color: Colors.green.shade600, fontWeight: FontWeight.bold),
                    length: 4,
                    animationType: AnimationType.scale,
                    validator: (v) => null,
                    pinTheme: PinTheme(
                      shape: PinCodeFieldShape.underline,
                      fieldHeight: 50,
                      fieldWidth: 40,
                      activeColor: Theme.of(context).primaryColor,
                      inactiveColor: Theme.of(context).indicatorColor,
                    ),
                    cursorColor: Colors.black,
                    animationDuration: const Duration(milliseconds: 300),
                    errorAnimationController: errorController,
                    controller: textEditingController,
                    keyboardType: TextInputType.number,
                    boxShadows: const [BoxShadow(offset: Offset(0, 1), color: Colors.black12, blurRadius: 10)],
                    onCompleted: (v) {
                      debugPrint("Completed");
                    },
                    onChanged: (value) {
                      debugPrint(value);
                      setState(() {
                        smsSent = value;
                      });
                    },
                    beforeTextPaste: (text) {
                      debugPrint("Allowing to paste $text");
                      return true;
                    },
                  ),
                const SizedBox(height: 15),
                Text(S.of(context).smsHasBeenSentTo + (widget.user?.phone ?? ''), style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
                const SizedBox(height: 80),
                isLoading
                    ? const CupertinoActivityIndicator()
                    : BlockButtonWidget(
                  onPressed: () async {
                    setState(() => isLoading = true);

                    if (skipOTP) {
                      currentUser.value.updatePhoneVerification(true); // ✅ التفعيل اليدوي
                      widget.valueChangedCallback?.call(true);
                      setState(() => isLoading = false);
                      return;
                    }

                    try {
                      bool isVerified = await verifyOTP(smsSent);
                      if (!isVerified) {
                        ScaffoldMessenger.of(widget.scaffoldKey?.currentContext ?? context).showSnackBar(
                          const SnackBar(behavior: SnackBarBehavior.floating, content: Text("Code doesn't match")),
                        );
                      } else {
                        widget.valueChangedCallback?.call(true);
                      }
                    } catch (e) {
                      print(e);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(behavior: SnackBarBehavior.fixed, content: Text("Code doesn't match")),
                      );
                    }

                    setState(() => isLoading = false);
                  },
                  color: Theme.of(context).colorScheme.secondary,
                  text: Text(
                    S.of(context).verify.toUpperCase(),
                    style: Theme.of(context).textTheme.headlineSmall?.merge(
                      TextStyle(color: Theme.of(context).primaryColor),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 30,
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 13, horizontal: config.App(context).appWidth(42)),
            decoration: BoxDecoration(
              color: Theme.of(context).focusColor.withOpacity(0.05),
              borderRadius: const BorderRadius.only(topRight: Radius.circular(20), topLeft: Radius.circular(20)),
            ),
            child: Container(
              width: 30,
              decoration: BoxDecoration(
                color: Theme.of(context).focusColor.withOpacity(0.8),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
