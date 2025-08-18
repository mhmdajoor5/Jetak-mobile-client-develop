import 'package:intercom_flutter/intercom_flutter.dart';
import '../models/user.dart';

class IntercomService {
  static Future<void> loginUser(User user) async {
    try {
      if (user.id != null && user.name != null && user.name!.isNotEmpty) {
        await Intercom.instance.loginIdentifiedUser(
          userId: user.id!,
          email: user.email ?? '',
          // name: user.name!,
        );
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
        print('✅ Intercom: Logged in ${user.name}');
      } else {
        await Intercom.instance.loginUnidentifiedUser();
        print('⚠️ Intercom: Logged unidentified user');
      }
    } catch (e) {
      print('❌ Intercom login error: $e');
      await Intercom.instance.loginUnidentifiedUser();
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
      await Intercom.instance.displayMessenger();
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
