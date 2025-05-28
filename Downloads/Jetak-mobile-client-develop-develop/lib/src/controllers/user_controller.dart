import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../helpers/helper.dart';
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

  BuildContext? get context =>
      state?.context ?? scaffoldKey.currentContext;

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

    if (!(loginFormKey.currentState?.validate() ?? false)) {
      _showSnackBar(S.of(context!).please_fill_all_fields);
      return;
    }
    loginFormKey.currentState!.save();
    _showLoader();
    try {
      final value = await repository.login(user);
      _hideLoader();
      if (value != null && value.apiToken != null) {
        ScaffoldMessenger.of(context!).showSnackBar(
          SnackBar(
            content: Text(S.of(context!).login_successful),
            duration: const Duration(seconds: 1),
          ),
        );
        Navigator.of(context!).pushReplacementNamed('/Pages', arguments: 2);
      } else {
        _showSnackBar(S.of(context!).wrong_email_or_password);
      }
    } on FirebaseAuthException catch (e) {
      _hideLoader();
      if (e.code == 'wrong-password') {
        _showSnackBar(S.of(context!).wrong_password); // أضف هذه الترجمة في ملف l10n
      } else if (e.code == 'user-not-found') {
        _showSnackBar(S.of(context!).this_account_not_exist);
      } else {
        _showSnackBar(e.message ?? 'An error occurred');
      }
    } catch (e) {
      _hideLoader();
      _showSnackBar(S.of(context!).this_account_not_exist);
    }
  }

  Future<void> register() async {
    if (context == null) return;
    FocusScope.of(context!).unfocus();
    if (!(loginFormKey.currentState?.validate() ?? false)) return;
    loginFormKey.currentState?.save();
    _showLoader();
    try {
      final value = await repository.register(user);
      _hideLoader();
      if (value != null && value.apiToken != null) {
        ScaffoldMessenger.of(context!).showSnackBar(
          SnackBar(
            content: Text(S.of(context!).register_successful),
            duration: const Duration(seconds: 1),
          ),
        );
        await Future.delayed(const Duration(milliseconds: 500));
        Navigator.of(context!).pushReplacementNamed('/Pages', arguments: 2);
      } else {
        _showSnackBar(S.of(context!).wrong_email_or_password);
      }
    } catch (e) {
      _hideLoader();
      _showSnackBar(S.of(context!).this_email_account_exists);
    }
  }

  Future<void> verifyPhone(model.User user) async {
    if (context == null) return;

    final PhoneVerificationCompleted verificationCompleted =
        (PhoneAuthCredential credential) {
      // You could log in the user automatically here if needed.
    };

    final PhoneVerificationFailed verificationFailed =
        (FirebaseAuthException e) {
      _showSnackBar(e.message ?? 'Phone verification failed');
      print(e);
    };

    final PhoneCodeSent codeSent =
        (String verificationId, int? forceResendingToken) {
      repository.currentUser.value.verificationId = verificationId;
      Navigator.push(
        context!,
        MaterialPageRoute(
          builder: (ctx) => MobileVerification2(
            onVerified: (v) {
              Navigator.of(ctx).pushReplacementNamed('/Pages', arguments: 2);
            },
          ),
        ),
      );
    };

    final PhoneCodeAutoRetrievalTimeout autoRetrievalTimeout =
        (String verificationId) {
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

  Future<void> loginWithGoogle() async {
    if (context == null) return;
    _showLoader();
    try {
      final account = await GoogleSignIn().signIn();
      if (account == null) throw 'canceled';
      final auth = await account.authentication;
      final token = auth.idToken;
      final response = await http.post(
        Uri.parse('https://your.api.com/social-login/google'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'token': token}),
      );
      if (response.statusCode == 200) {
        _hideLoader();
        _showSnackBar(S.of(context!).login_successful);
        Navigator.of(context!).pushReplacementNamed('/Pages', arguments: 2);
      } else {
        throw 'error';
      }
    } catch (e) {
      _hideLoader();
      _showSnackBar('Google login failed');
    }
  }

  Future<void> loginWithFacebook() async {
    if (context == null) return;
    _showLoader();
    try {
      final result = await FacebookAuth.instance.login();

      if (result.status != LoginStatus.success || result.accessToken == null) {
        throw 'Facebook login canceled or failed';
      }
      final token = result.accessToken?.toJson()['token'];

      if (token == null) {
        throw 'Token is null';
      }

      final response = await http.post(
        Uri.parse('https://your.api.com/social-login/facebook'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'token': token}),
      );

      if (response.statusCode == 200) {
        _hideLoader();
        _showSnackBar(S.of(context!).login_successful);
        Navigator.of(context!).pushReplacementNamed('/Pages', arguments: 2);
      } else {
        throw 'API error';
      }
    } catch (e) {
      _hideLoader();
      _showSnackBar('فشل تسجيل الدخول باستخدام فيسبوك');
      debugPrint('Facebook login error: $e');
    }
  }


//   Future<void> loginWithApple() async {
//     if (context == null) return;
//     _showLoader();
//     try {
//       final credential = await SignInWithApple.getAppleIDCredential(
//         scopes: [AppleIDAuthorizationScopes.email, AppleIDAuthorizationScopes.fullName],
//       );
//       final oauthCred = OAuthProvider("apple.com").credential(
//         idToken: credential.identityToken,
//         accessToken: credential.authorizationCode,
//       );
//       final userCred = await FirebaseAuth.instance.signInWithCredential(oauthCred);
//       if (userCred.user != null) {
//         _hideLoader();
//         _showSnackBar(S.of(context!).login_successful);
//         Navigator.of(context!).pushReplacementNamed('/Pages', arguments: 2);
//       }
//     } catch (e) {
//       _hideLoader();
//       _showSnackBar('Apple login failed');
//     }
//   }
// }

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
              content: Text(S.of(context!).your_reset_link_has_been_sent_to_your_email),
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

  void _showSnackBar(String message) {
    if (context != null) {
      ScaffoldMessenger.of(context!).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }
}
