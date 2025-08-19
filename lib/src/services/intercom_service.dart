import 'dart:io';
import 'package:intercom_flutter/intercom_flutter.dart';
import 'package:flutter/material.dart';

class IntercomService {
  static final IntercomService _instance = IntercomService._internal();
  factory IntercomService() => _instance;
  IntercomService._internal();

  bool _isInitialized = false;
  bool _isUserLoggedIn = false;

  /// تهيئة Intercom مع معالجة الأخطاء
  Future<bool> initialize({
    required String appId,
    String? iosApiKey,
    String? androidApiKey,
  }) async {
    if (_isInitialized) {
      print('Intercom already initialized');
      return true;
    }

    try {
      await Intercom.instance.initialize(
        appId,
        iosApiKey: iosApiKey,
        androidApiKey: androidApiKey,
      );
      
      _isInitialized = true;
      print('Intercom initialized successfully');
      
      // إخفاء الـ launcher الافتراضي
      await Intercom.instance.setLauncherVisibility(IntercomVisibility.gone);
      
      return true;
    } catch (e) {
      print('Error initializing Intercom: $e');
      return false;
    }
  }

  /// تسجيل المستخدم في Intercom
  Future<bool> loginUser({
    String? userId,
    String? email,
    String? name,
  }) async {
    if (!_isInitialized) {
      print('Intercom not initialized');
      return false;
    }

    try {
      if (userId != null && userId.isNotEmpty) {
        await Intercom.instance.loginIdentifiedUser(
          userId: userId,
          email: email,
        );
      } else if (email != null && email.isNotEmpty) {
        await Intercom.instance.loginIdentifiedUser(
          email: email,
        );
      } else {
        await Intercom.instance.loginUnidentifiedUser();
      }

      // تحديث بيانات المستخدم إذا كانت متوفرة
      if (name != null && name.isNotEmpty) {
        await Intercom.instance.updateUser(
          name: name,
        );
      }

      _isUserLoggedIn = true;
      print('User logged in to Intercom successfully');
      return true;
    } catch (e) {
      print('Error logging user to Intercom: $e');
      return false;
    }
  }

  /// فتح محادثة Intercom
  Future<void> openMessenger() async {
    if (!_isInitialized) {
      print('Intercom not initialized');
      return;
    }

    try {
      await Intercom.instance.displayMessenger();
    } catch (e) {
      print('Error opening Intercom messenger: $e');
    }
  }

  /// إخفاء محادثة Intercom
  Future<void> hideMessenger() async {
    if (!_isInitialized) {
      return;
    }

    try {
      await Intercom.instance.hideMessenger();
    } catch (e) {
      print('Error hiding Intercom messenger: $e');
    }
  }

  /// إرسال رسالة إلى Intercom
  Future<void> sendMessage(String message) async {
    if (!_isInitialized || !_isUserLoggedIn) {
      print('Intercom not ready for messaging');
      return;
    }

    try {
      // Intercom Flutter plugin لا يدعم sendMessage مباشرة
      // بدلاً من ذلك، نفتح المحادثة
      await Intercom.instance.displayMessenger();
    } catch (e) {
      print('Error opening Intercom messenger: $e');
    }
  }

  /// إرسال token الإشعارات إلى Intercom
  Future<void> sendTokenToIntercom(String token) async {
    if (!_isInitialized) {
      print('Intercom not initialized');
      return;
    }

    try {
      await Intercom.instance.sendTokenToIntercom(token);
      print('Token sent to Intercom successfully');
    } catch (e) {
      print('Error sending token to Intercom: $e');
    }
  }

  /// تسجيل خروج المستخدم من Intercom
  Future<void> logout() async {
    if (!_isInitialized) {
      return;
    }

    try {
      await Intercom.instance.logout();
      _isUserLoggedIn = false;
      print('User logged out from Intercom');
    } catch (e) {
      print('Error logging out from Intercom: $e');
    }
  }

  /// التحقق من حالة Intercom
  bool get isInitialized => _isInitialized;
  bool get isUserLoggedIn => _isUserLoggedIn;

  /// إعادة تعيين الحالة (للتطوير)
  void reset() {
    _isInitialized = false;
    _isUserLoggedIn = false;
  }
}
