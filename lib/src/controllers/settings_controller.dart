import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../helpers/helper.dart';
import '../models/card_item.dart';
import '../models/credit_card.dart';
import '../models/user.dart' as userModel;
import '../pages/mobile_verification_2.dart';
import '../repository/user_repository.dart' as repository;

class SettingsController extends ControllerMVC {
  CreditCard creditCard = new CreditCard();
  late GlobalKey<FormState> loginFormKey;
  late GlobalKey<ScaffoldState> scaffoldKey;
  late OverlayEntry loader;

  SettingsController() {
    loginFormKey = new GlobalKey<FormState>();
    this.scaffoldKey = new GlobalKey<ScaffoldState>();

    listenForUser();
  }

  Future<void> verifyPhone(userModel.User user) async {
    autoRetrieve(String verId) {
      repository.currentUser.value.verificationId = verId;
    }

    final PhoneCodeSent smsCodeSent = (String verId, [int? forceCodeResent]) {
      repository.currentUser.value.verificationId = verId;
      Navigator.push(
        scaffoldKey.currentContext!,
        MaterialPageRoute(
            builder: (context) => MobileVerification2(
                  onVerified: (v) {
                    Navigator.of(scaffoldKey.currentContext!).pushNamed('/Settings');
                  },
                )),
      );
    } as PhoneCodeSent;
    verifiedSuccess(AuthCredential auth) {
      Navigator.of(scaffoldKey.currentContext!).pushNamed('/Settings');
    }
    verifyFailed(FirebaseAuthException e) {
      ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(SnackBar(
        content: Text(e.message!),
      ));
      print(e.toString());
    }
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: user.phone,
      timeout: const Duration(seconds: 5),
      verificationCompleted: verifiedSuccess,
      verificationFailed: verifyFailed,
      codeSent: smsCodeSent,
      codeAutoRetrievalTimeout: autoRetrieve,
    );
  }

  Future<void> update(userModel.User user) async {
    user.deviceToken = null;
    repository.update(user).then((value) {
      setState(() {});
      ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(SnackBar(
        content: Text(S.of(state!.context).profile_settings_updated_successfully),
      ));
    });
  }

  void updateCreditCard(CreditCard creditCard) {
    repository.setCreditCard(creditCard).then((value) {
      setState(() {});
      ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(SnackBar(
        content: Text(S.of(state!.context).payment_settings_updated_successfully),
      ));
    });
  }

  void listenForUser() async {
    creditCard = CreditCard();
    CardItem? cardItem = (await Helper.getSavedCards()).firstOrNull;
    creditCard.cvc = cardItem?.cardCVV??'';
    creditCard.number = cardItem?.cardNumber??'';
    creditCard.holderName = cardItem?.cardHolderName??'';
    creditCard.expiryDate = cardItem?.cardExpirationDate??'';
    // creditCard = await repository.getCreditCard();
    setState(() {});
  }

  Future<void> refreshSettings() async {
    creditCard = CreditCard();
  }
}
