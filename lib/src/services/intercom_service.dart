import 'dart:io';
import 'package:intercom_flutter/intercom_flutter.dart';
import '../models/user.dart';

class IntercomService {
  static Future<void> loginUser(User user) async {
    try {
      print('🔄 Intercom: Attempting to login user...');
      print('🔄 Intercom: User ID: ${user.id}');
      print('🔄 Intercom: User Name: ${user.name}');
      print('🔄 Intercom: User Email: ${user.email}');
      
      if (user.id != null && user.name != null && user.name!.isNotEmpty) {
        print('🔄 Intercom: Logging in identified user...');
        
        await Intercom.instance.loginIdentifiedUser(
          userId: user.id!,
          email: user.email ?? '',
          // name: user.name!,
        );
        
        print('🔄 Intercom: Updating user data...');
        
        await Intercom.instance.updateUser(
          email: user.email ?? '',
          name: user.name!,
          phone: user.phone ?? '',
          company: 'Carry Eats Hub',
          customAttributes: {
            'user_id': user.id!,
            'phone': user.phone ?? '',
            'address': user.address ?? '',
            'verified_phone': user.verifiedPhone ? 'true' : 'false',
          },
        );
        
        print('✅ Intercom: Successfully logged in ${user.name}');
      } else {
        print('🔄 Intercom: Logging in unidentified user...');
        await Intercom.instance.loginUnidentifiedUser();
        print('⚠️ Intercom: Logged unidentified user');
      }
    } catch (e) {
      print('❌ Intercom login error: $e');
      print('❌ Intercom login error stack trace: ${e.toString()}');
      try {
        await Intercom.instance.loginUnidentifiedUser();
        print('⚠️ Intercom: Fallback to unidentified user');
      } catch (fallbackError) {
        print('❌ Intercom fallback error: $fallbackError');
      }
    }
  }

  static Future<void> logoutUser() async {
    try {
      await Intercom.instance.logout();
      print('✅ Intercom: Logged out');
    } catch (e) {
      print('❌ Intercom logout error: $e');
    }
  }

  static Future<void> updateUserData(User user) async {
    try {
      if (user.id != null && user.name != null) {
        await Intercom.instance.updateUser(
          email: user.email ?? '',
          name: user.name!,
          phone: user.phone ?? '',
          company: 'Carry Eats Hub',
          customAttributes: {
            'user_id': user.id!,
            'phone': user.phone ?? '',
            'address': user.address ?? '',
            'verified_phone': user.verifiedPhone ? 'true' : 'false',
          },
        );
        print('✅ Intercom: Updated user ${user.name}');
      }
    } catch (e) {
      print('❌ Intercom update user error: $e');
    }
  }

  // دالة جديدة لفتح Intercom مع مظهر مخصص
  static Future<void> displayCustomMessenger() async {
    try {
      // إخفاء جميع الإشعارات في التطبيق
      await Intercom.instance.setInAppMessagesVisibility(IntercomVisibility.gone);
      
      // إخفاء شريط التطبيق (App Bar) في Intercom
      await Intercom.instance.setLauncherVisibility(IntercomVisibility.gone);
      
      // فتح messenger مع إعدادات مخصصة
      await Intercom.instance.displayMessenger();
      
      print('✅ Intercom: Custom messenger displayed with hidden elements');
    } catch (e) {
      print('❌ Intercom custom messenger error: $e');
      // في حالة الخطأ، افتح messenger عادي
      try {
        await Intercom.instance.displayMessenger();
      } catch (displayError) {
        print('❌ Intercom display messenger error: $displayError');
        // إذا فشل كل شيء، حاول إعادة تهيئة Intercom على Android
        if (Platform.isAndroid) {
          print('🔄 Attempting to reinitialize Intercom on Android...');
          try {
            await Intercom.instance.initialize(
              'j3he2pue',
              androidApiKey: 'android_sdk-d8df6307ae07677807b288a2d5138821b8bfe4f9',
            );
            await Intercom.instance.displayMessenger();
          } catch (reinitError) {
            print('❌ Intercom reinitialization failed: $reinitError');
          }
        }
      }
    }
  }

  // دالة لإخفاء جميع الإشعارات في التطبيق
  static Future<void> hideInAppMessages() async {
    try {
      await Intercom.instance.setInAppMessagesVisibility(IntercomVisibility.gone);
      print('✅ Intercom: In-app messages hidden');
    } catch (e) {
      print('❌ Intercom hide messages error: $e');
    }
  }

  // دالة لإظهار الإشعارات في التطبيق
  static Future<void> showInAppMessages() async {
    try {
      await Intercom.instance.setInAppMessagesVisibility(IntercomVisibility.visible);
      print('✅ Intercom: In-app messages shown');
    } catch (e) {
      print('❌ Intercom show messages error: $e');
    }
  }
}
