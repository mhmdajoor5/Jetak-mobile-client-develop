import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../helpers/custom_trace.dart';
import '../repository/settings_repository.dart' as settingRepo;
import '../repository/user_repository.dart' as userRepo;

class SplashScreenController extends ControllerMVC {
  ValueNotifier<Map<String, double>> progress = new ValueNotifier(new Map());
  late GlobalKey<ScaffoldState> scaffoldKey;
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  SplashScreenController() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
    // Should define these variables before the app loaded
    progress.value = {"Setting": 0, "User": 0};
  }

  @override
  void initState() {
    super.initState();
    FirebaseMessaging.instance.requestPermission(sound: true, badge: true, alert: true);
    configureFirebase(firebaseMessaging);
    settingRepo.setting.addListener(() {
      if (settingRepo.setting.value.appName != '') {
        progress.value["Setting"] = 41;
        // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
        progress.notifyListeners();
      }
    });
    userRepo.currentUser.addListener(() {
      if (userRepo.currentUser.value.auth != null) {
        progress.value["User"] = 59;
        progress.notifyListeners();
      }
    });
    Timer(Duration(seconds: 20), () {
      ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(SnackBar(
        content: Text(S
            .of(state!.context)
            .verify_your_internet_connection),
      ));
        });
  }


  void configureFirebase(FirebaseMessaging _firebaseMessaging) {
    try {
      notificationOnResume;
      notificationOnLaunch;
      notificationOnMessage;
      // _firebaseMessaging.configure(
      //   onMessage: notificationOnMessage,
      //   onLaunch: notificationOnLaunch,c
      //   onResume: notificationOnResume,
      // );
    } catch (e) {
      print(CustomTrace(StackTrace.current, message: e.toString()));
      print(CustomTrace(StackTrace.current, message: 'Error Config Firebase'));
    }
  }

  Future notificationOnResume(Map<String, dynamic> message) async {
    print(CustomTrace(StackTrace.current, message: message['data']['id']));
    try {
      if (message['data']['id'] == "orders") {
        settingRepo.navigatorKey.currentState!.pushReplacementNamed('/Pages', arguments: 3);
      } else if (message['data']['id'] == "messages") {
        settingRepo.navigatorKey.currentState!.pushReplacementNamed('/Pages', arguments: 4);
      }
    } catch (e) {
      print(CustomTrace(StackTrace.current, message: e.toString()));
    }
  }

  Future notificationOnLaunch(Map<String, dynamic> message) async {
    String messageId = await settingRepo.getMessageId();
    try {
      if (messageId != message['google.message_id']) {
        await settingRepo.saveMessageId(message['google.message_id']);
        if (message['data']['id'] == "orders") {
          settingRepo.navigatorKey.currentState!.pushReplacementNamed('/Pages', arguments: 3);
        } else if (message['data']['id'] == "messages") {
          settingRepo.navigatorKey.currentState!.pushReplacementNamed('/Pages', arguments: 4);
        }
      }
    } catch (e) {
      print(CustomTrace(StackTrace.current, message: e.toString()));
    }
  }

  Future notificationOnMessage(Map<String, dynamic> message) async {
    Fluttertoast.showToast(
      msg: message['notification']['title'],
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.TOP,
      timeInSecForIosWeb: 6,
    );
  }
}

