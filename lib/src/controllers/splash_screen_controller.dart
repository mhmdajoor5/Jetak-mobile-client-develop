import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../helpers/custom_trace.dart';
import '../repository/settings_repository.dart' as settingRepo;
import '../repository/user_repository.dart' as userRepo;
import '../models/notification_refresh_notifier.dart';

class SplashScreenController extends ControllerMVC {
  ValueNotifier<Map<String, double>> progress = ValueNotifier(Map<String, double>());
  late GlobalKey<ScaffoldState> scaffoldKey;
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  SplashScreenController() {
    this.scaffoldKey = GlobalKey<ScaffoldState>();
    // Should define these variables before the app loaded
    progress.value = {"Setting": 0, "User": 0};
  }

  @override
  void initState() {
    super.initState();
    _initializeFirebase();
    _initializeListeners();
    _startTimeoutTimer();
  }

  void _initializeFirebase() async {
    try {
      // Request notification permissions
      NotificationSettings settings = await firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('User granted permission');
        await _configureFirebase();
      } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
        print('User granted provisional permission');
        await _configureFirebase();
      } else {
        print('User declined or has not accepted permission');
      }
    } catch (e) {
      print(CustomTrace(StackTrace.current, message: 'Error initializing Firebase: $e'));
    }
  }

  Future<void> _configureFirebase() async {
    try {
      // Get FCM token
      String? token = await firebaseMessaging.getToken();
      print('FCM Token: $token');

      // Handle token refresh
      firebaseMessaging.onTokenRefresh.listen((newToken) {
        print('FCM Token refreshed: $newToken');
        // TODO: Send token to server
      });

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('Got a message whilst in the foreground!');
        _handleForegroundMessage(message);
      });

      // Handle background messages when app is opened
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print('A new onMessageOpenedApp event was published!');
        _handleNotificationTap(message);
      });

      // Handle notification when app is launched from terminated state
      RemoteMessage? initialMessage = await firebaseMessaging.getInitialMessage();
      if (initialMessage != null) {
        print('App launched from notification');
        _handleNotificationTap(initialMessage);
      }

    } catch (e) {
      print(CustomTrace(StackTrace.current, message: 'Error configuring Firebase: $e'));
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    try {
      final title = message.notification?.title ?? 'New Notification';
      final body = message.notification?.body ?? 'You have a new notification';
      
      // Show toast notification
      Fluttertoast.showToast(
        msg: '$title: $body',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 6,
        backgroundColor: Colors.black87,
        textColor: Colors.white,
        fontSize: 16.0,
      );

      // Trigger notification refresh
      _refreshNotifications();
      NotificationRefreshNotifier.trigger();
    } catch (e) {
      print(CustomTrace(StackTrace.current, message: 'Error handling foreground message: $e'));
    }
  }

  void _handleNotificationTap(RemoteMessage message) {
    try {
      final data = message.data;
      
      // Navigate based on notification type
      if (data['id'] == 'orders' || data['type']?.contains('Order') == true) {
        // Navigate to orders page
        _navigateToPage(3);
      } else if (data['id'] == 'messages' || data['type']?.contains('Message') == true) {
        // Navigate to messages page
        _navigateToPage(4);
      } else {
        // Navigate to notifications page
        _navigateToNotifications();
      }
    } catch (e) {
      print(CustomTrace(StackTrace.current, message: 'Error handling notification tap: $e'));
    }
  }

  void _navigateToPage(int pageIndex) {
    try {
      settingRepo.navigatorKey.currentState?.pushReplacementNamed('/Pages', arguments: pageIndex);
    } catch (e) {
      print(CustomTrace(StackTrace.current, message: 'Error navigating to page: $e'));
    }
  }

  void _navigateToNotifications() {
    try {
      settingRepo.navigatorKey.currentState?.pushNamed('/Notifications');
    } catch (e) {
      print(CustomTrace(StackTrace.current, message: 'Error navigating to notifications: $e'));
    }
  }

  void _refreshNotifications() {
    try {
      // This will trigger notification refresh in the app
      // You can implement a global state management solution here
      print('Refreshing notifications...');
    } catch (e) {
      print(CustomTrace(StackTrace.current, message: 'Error refreshing notifications: $e'));
    }
  }

  void _initializeListeners() {
    settingRepo.setting.addListener(() {
      if (settingRepo.setting.value.appName != '') {
        progress.value["Setting"] = 41;
        progress.notifyListeners();
      }
    });

    userRepo.currentUser.addListener(() {
      if (userRepo.currentUser.value.auth != null) {
        progress.value["User"] = 59;
        progress.notifyListeners();
      }
    });
  }

  void _startTimeoutTimer() {
    Timer(Duration(seconds: 20), () {
      if (scaffoldKey.currentContext != null) {
        ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(
          SnackBar(
            content: Text(S.of(scaffoldKey.currentContext!).verify_your_internet_connection),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  // Legacy methods for backward compatibility
  Future notificationOnResume(Map<String, dynamic> message) async {
    return _handleNotificationTap(RemoteMessage(data: message));
  }

  Future notificationOnLaunch(Map<String, dynamic> message) async {
    String messageId = await settingRepo.getMessageId();
    try {
      if (messageId != message['google.message_id']) {
        await settingRepo.saveMessageId(message['google.message_id']);
        return _handleNotificationTap(RemoteMessage(data: message));
      }
    } catch (e) {
      print(CustomTrace(StackTrace.current, message: e.toString()));
    }
  }

  Future notificationOnMessage(Map<String, dynamic> message) async {
    try {
      final title = message['notification']?['title'] ?? 'New Notification';
      final body = message['notification']?['body'] ?? 'You have a new notification';
      
      Fluttertoast.showToast(
        msg: '$title: $body',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 6,
      );
    } catch (e) {
      print(CustomTrace(StackTrace.current, message: 'Error in notificationOnMessage: $e'));
    }
  }

  // Method to configure Firebase (legacy compatibility)
  void configureFirebase(FirebaseMessaging firebaseMessaging) {
    // This method is kept for compatibility but the actual configuration
    // is now handled in _configureFirebase()
    print('configureFirebase called (legacy method)');
  }
}

