import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../helpers/helper.dart';
import '../helpers/my_toast_helper.dart';
import '../models/user.dart' as model;
import '../pages/mobile_verification_2.dart';
import '../repository/user_repository.dart' as repository;

class UserController extends ControllerMVC {
  model.User user = model.User();
  bool hidePassword = true;
  bool loading = false;
  late GlobalKey<FormState> loginFormKey;
  late GlobalKey<ScaffoldState> scaffoldKey;
  late FirebaseMessaging _firebaseMessaging;
  late OverlayEntry loader;
  bool _isLoaderVisible = false;

  UserController() {
    loginFormKey = GlobalKey<FormState>();
    scaffoldKey = GlobalKey<ScaffoldState>();
    _firebaseMessaging = FirebaseMessaging.instance;

    _initializeFirebaseMessaging();
  }

  void _initializeFirebaseMessaging() async {
    try {
      String? token = await _firebaseMessaging.getToken();
      if (token != null) {
        user.deviceToken = token;
      }
    } catch (e) {
      print('Notification not configured: $e');
    }
  }

  BuildContext? get context => state?.context ?? scaffoldKey.currentContext;

  void _showLoader() {
    if (!_isLoaderVisible && context != null) {
      loader = Helper.overlayLoader(context!);
      Overlay.of(context!)?.insert(loader);
      _isLoaderVisible = true;
    }
  }

  void _hideLoader() {
    if (_isLoaderVisible) {
      loader.remove();
      _isLoaderVisible = false;
    }
  }

  void login() async {
    if (context == null) return;
    FocusScope.of(context!).unfocus();
    if (loginFormKey.currentState?.validate() ?? false) {
      loginFormKey.currentState?.save();
      _showLoader();
      try {
        final value = await repository.login(user);
        if (value != null && value.apiToken != null) {
          Navigator.of(context!).pushReplacementNamed('/Pages', arguments: 2);
          MyToastHelper.successBar(S.current.login_success , color: Colors.green);
        } else {
          _showSnackBar(S.of(context!).wrong_email_or_password);
        }
      } catch (e) {
        print(e);
        _showSnackBar(S.of(context!).this_account_not_exist);
      } finally {
        _hideLoader();
      }
    }
  }

  Future<void> register() async {
    if (context == null) return;
    FocusScope.of(context!).unfocus();
    _showLoader();
    try {
      final value = await repository.register(user);
      if (value != null && value.apiToken != null) {
        Navigator.of(context!).pushReplacementNamed('/Pages', arguments: 2);
      } else {
        _showSnackBar(S.of(context!).wrong_email_or_password);
      }
    } catch (e) {
      _showSnackBar(S.of(context!).this_email_account_exists);
    } finally {
      _hideLoader();
    }
  }

  Future<void> verifyPhone(model.User user) async {
    if (context == null) return;

    final PhoneVerificationCompleted verificationCompleted = (
      PhoneAuthCredential credential,
    ) {
      // You could log in the user automatically here if needed.
    };

    final PhoneVerificationFailed verificationFailed = (
      FirebaseAuthException e,
    ) {
      _showSnackBar(e.message ?? 'Phone verification failed');
      print(e);
    };

    final PhoneCodeSent codeSent = (
      String verificationId,
      int? forceResendingToken,
    ) {
      repository.currentUser.value.verificationId = verificationId;
      Navigator.push(
        context!,
        MaterialPageRoute(
          builder:
              (ctx) => MobileVerification2(
                onVerified: (v) {
                  Navigator.of(
                    ctx,
                  ).pushReplacementNamed('/Pages', arguments: 2);
                },
              ),
        ),
      );
    };

    final PhoneCodeAutoRetrievalTimeout autoRetrievalTimeout = (
      String verificationId,
    ) {
      repository.currentUser.value.verificationId = verificationId;
    };

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: user.phone,
        timeout: const Duration(seconds: 5),
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: autoRetrievalTimeout,
      );
    } catch (e) {
      _showSnackBar('Phone verification failed');
      print(e);
    }
  }

  void resetPassword() async {
    if (context == null) return;
    FocusScope.of(context!).unfocus();
    if (loginFormKey.currentState?.validate() ?? false) {
      loginFormKey.currentState?.save();
      _showLoader();
      try {
        final success = await repository.resetPassword(user);
        if (success == true) {
          ScaffoldMessenger.of(context!).showSnackBar(
            SnackBar(
              content: Text(
                S.of(context!).your_reset_link_has_been_sent_to_your_email,
              ),
              action: SnackBarAction(
                label: S.of(context!).login,
                onPressed: () {
                  Navigator.of(context!).pushReplacementNamed('/Login');
                },
              ),
              duration: const Duration(seconds: 10),
            ),
          );
        } else {
          _showSnackBar(S.of(context!).error_verify_email_settings);
        }
      } catch (e) {
        _showSnackBar(S.of(context!).error_verify_email_settings);
      } finally {
        _hideLoader();
      }
    }
  }

  Future<void> loginWithGoogle() async {
    _showLoader();
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        _hideLoader();
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

      Navigator.of(context!).pushReplacementNamed('/Pages', arguments: 0);
      MyToastHelper.successBar('تم تسجيل الدخول باستخدام Google', color: Colors.green);
    } catch (e) {
      print('Google sign-in error: $e');
      _showSnackBar('فشل تسجيل الدخول باستخدام Google');
    } finally {
      _hideLoader();
    }
  }

  Future<void> loginWithFacebook() async {
    _showLoader();
    try {
      final LoginResult result = await FacebookAuth.instance.login();

      if (result.status == LoginStatus.success) {
        final OAuthCredential credential = FacebookAuthProvider.credential(result.accessToken!.tokenString);
        final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

        Navigator.of(context!).pushReplacementNamed('/Pages', arguments: 2);
        MyToastHelper.successBar('تم تسجيل الدخول باستخدام Facebook', color: Colors.green);
      } else {
        _showSnackBar('فشل تسجيل الدخول باستخدام Facebook');
      }
    } catch (e) {
      print('Facebook sign-in error: $e');
      _showSnackBar('فشل تسجيل الدخول باستخدام Facebook');
    } finally {
      _hideLoader();
    }
  }

  void _showSnackBar(String message) {
    if (context != null) {
      ScaffoldMessenger.of(
        context!,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }
}
