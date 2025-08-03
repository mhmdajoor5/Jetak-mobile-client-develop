import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart' as userModel show User;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'dart:io';

import '../../generated/l10n.dart';
import '../helpers/helper.dart';
import '../models/user.dart' as model;
import '../pages/mobile_verification_2.dart';
import '../repository/user_repository.dart' as repository;
import '../repository/user_repository.dart';
import '../repository/user_repository.dart' as userRepo;

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
      Overlay.of(context!).insert(loader);
      _isLoaderVisible = true;
    }
  }

  void _hideLoader() {
    if (_isLoaderVisible) {
      loader.remove();
      _isLoaderVisible = false;
    }
  }

  void someFunctionThatNeedsToken() {
    if (repository.currentUser.value.apiToken == null) {
      print('No API token found, cannot proceed.');
      return;
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
      final user = await repository.login(this.user);
      _hideLoader();

      if (user.apiToken != null) {
        ScaffoldMessenger.of(context!).showSnackBar(
          SnackBar(
            content: Text(S.of(context!).login_successful),
            duration: const Duration(seconds: 1),
          ),
        );

        if (!user.verifiedPhone) {
          Navigator.of(context!).pushReplacementNamed(
            '/VerifyCode',
            arguments: {'phone': user.phone},
          );
        } else {
          Navigator.of(context!).pushReplacementNamed(
            '/Pages',
            arguments: 0,
          );
        }
      } else {
        _showSnackBar(S.of(context!).wrong_email_or_password);
      }
    } on FirebaseAuthException catch (e) {
      _hideLoader();
      if (e.code == 'wrong-password') {
        _showSnackBar(S.of(context!).wrong_password);
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
      if (value.apiToken != null) {
        ScaffoldMessenger.of(context!).showSnackBar(
          SnackBar(
            content: Text(S.of(context!).register_successful),
            duration: const Duration(seconds: 1),
          ),
        );
        await Future.delayed(const Duration(milliseconds: 500));
        Navigator.of(context!).pushReplacementNamed('/Pages', arguments: 0);
      } else {
        _showSnackBar(S.of(context!).wrong_email_or_password);
      }
    } catch (e) {
      _hideLoader();
      _showSnackBar(S.of(context!).this_email_account_exists);
    }
  }

  Future<void> registerWithGoogle() async {
    if (context == null) return;
    final loaderTimer = Timer(const Duration(milliseconds: 300), _showLoader);

    try {
      final googleSignIn = GoogleSignIn();
      final account = await googleSignIn.signIn();
      if (account == null) throw 'تم إلغاء تسجيل الدخول من قبل المستخدم';

      final auth = await account.authentication;
      if (auth.accessToken == null || auth.idToken == null) {
        throw 'بيانات Google مفقودة';
      }

      final credential = GoogleAuthProvider.credential(
        accessToken: auth.accessToken,
        idToken: auth.idToken,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final firebaseUser = userCredential.user;

      final response = await http.post(
        Uri.parse('https://carrytechnologies.co/api/register/social/google'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'provider': 'google',
          'token': auth.accessToken,
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        _hideLoader();
        _showSnackBar(S.of(context!).register_successful);
        Navigator.of(context!).pushReplacementNamed('/Pages', arguments: 0);
      } else {
        throw 'فشل التسجيل: ${response.body}';
      }
    } catch (e) {
      _hideLoader();
      _showSnackBar('فشل التسجيل باستخدام Google');
      print('Register error: $e');
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
              Navigator.of(ctx).pushReplacementNamed('/Pages', arguments: 0);
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
    final loaderTimer = Timer(const Duration(milliseconds: 300), _showLoader);

    try {
      final googleSignIn = GoogleSignIn();
      final account = await googleSignIn.signIn();
      if (account == null) throw 'Login cancelled';

      final auth = await account.authentication;
      if (auth.accessToken == null || auth.idToken == null) {
        throw 'Missing token(s)';
      }

      final credential = GoogleAuthProvider.credential(
        accessToken: auth.accessToken,
        idToken: auth.idToken,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);

      print('Access token: ${auth.accessToken}');
      print('ID token: ${auth.accessToken}');

      final response = await http.post(
        Uri.parse('https://carrytechnologies.co/api/login/social/google'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'provider': 'google',
          'token': auth.accessToken,
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        model.User userData = model.User.fromJSON(responseData['data']);
        repository.currentUser.value = userData;
        repository.currentUser.value.auth = true;
       // await repository.setCurrentUser(userData);

        _hideLoader();
        _showSnackBar(S.of(context!).login_successful);
        Navigator.of(context!).pushReplacementNamed('/Pages', arguments: 0);
      } else {
        print('Server error: ${response.body}');
        throw 'Server error: ${response.body}';
      }
    } catch (e) {
      _hideLoader();
      _showSnackBar('فشل تسجيل الدخول باستخدام Google');
      print('Login error: $e');
    }
  }

  // Future<void> loginWithFacebook() async {
  //   if (context == null) return;
  //   final loaderTimer = Timer(const Duration(milliseconds: 300), _showLoader);
  //
  //   try {
  //     final result = await FacebookAuth.instance.login();
  //
  //     if (result.status != LoginStatus.success || result.accessToken == null) {
  //       throw 'Facebook login canceled or failed';
  //     }
  //     final token = result.accessToken?.toJson()['token'];
  //
  //     if (token == null) {
  //       throw 'Token is null';
  //     }
  //
  //     final response = await http.post(
  //       Uri.parse('https://your.api.com/social-login/facebook'),
  //       headers: {'Content-Type': 'application/json'},
  //       body: jsonEncode({
  //         'token': token}),
  //     );
  //
  //     if (response.statusCode == 200) {
  //       _hideLoader();
  //       _showSnackBar(S.of(context!).login_successful);
  //       Navigator.of(context!).pushReplacementNamed('/Pages', arguments: 0);
  //     } else {
  //       throw 'API error';
  //     }
  //   } catch (e) {
  //     _hideLoader();
  //     _showSnackBar('فشل تسجيل الدخول باستخدام فيسبوك');
  //     debugPrint('Facebook login error: $e');
  //   }
  // }

  // Future<void> signInWithApple() async {
  //   if (Platform.isIOS) {
  //     try {
  //       final credential = await SignInWithApple.getAppleIDCredential(
  //         scopes: [
  //           AppleIDAuthorizationScopes.email,
  //           AppleIDAuthorizationScopes.fullName,
  //         ],
  //       );
  //
  //       print('User ID: ${credential.userIdentifier}');
  //       print('Email: ${credential.email}');
  //       print('Name: ${credential.givenName} ${credential.familyName}');
  //
  //     } catch (e) {
  //       print('Apple Sign-In Error: $e');
  //     }
  //   } else {
  //     print('Sign in with Apple is only available on iOS');
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

  Future<void> verifyOtpCode(String code) async {
    if (context == null) return;

    _showLoader();

    try {
      final response = await http.post(
        Uri.parse('https://carrytechnologies.co/api/submit-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "api_token": "…",
          "code": code,
        }),
      );

      _hideLoader();

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true || data['status'] == 'success') {
          final updatedUser = model.User.fromJSON(data['data']);
          repository.currentUser.value = updatedUser;
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(
            'current_user',
            jsonEncode(data['data']),
          );
          _showSnackBar("✅ تم التحقق بنجاح");

          Navigator.of(context!).pushNamedAndRemoveUntil(
            '/Pages',
                (route) => false,
            arguments: 0,
          );
          return;
        }
      }
      _showSnackBar("❌ كود خاطئ أو منتهي الصلاحية");
    } catch (e) {
      _hideLoader();
      _showSnackBar("حدث خطأ أثناء التحقق");
      print('OTP Verify Error: $e');
    }
  }


  Future<bool> checkPhoneVerification(
      String apiToken,
      String phoneNumber,
      BuildContext context,
      ) async {
    if (apiToken.isEmpty) {
      print('No API token found, skipping verification.');
      return false;
    }

    final uri = Uri.parse('https://carrytechnologies.co/api/verifyPhone?api_token=$apiToken');
    try {
      final response = await http.get(uri).timeout(Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final updatedUser = model.User.fromJSON(data['data']);
          repository.currentUser.value = updatedUser;
           repository.setCurrentUser(jsonEncode(data['data']));
          print('Phone verified successfully.');
          return true;  // تم التحقق
        } else {
          print('Phone not verified yet.');
          return false; // لم يتم التحقق بعد
        }
      }
      print('Failed to verify phone. Status code: ${response.statusCode}');
      return false;
    } catch (e) {
      print('Error during phone verification: $e');
      return false;
    }
  }

}
