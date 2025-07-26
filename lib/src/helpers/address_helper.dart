import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/address.dart';

class AddressHelper {
  /// إصلاح العنوان إذا كان لا يحتوي على إحداثيات
  static Future<Address?> fixAddressCoordinates(Address address) async {
    if (address.latitude != null && address.longitude != null) {
      return address; // العنوان صحيح بالفعل
    }

    try {
      // التحقق من صلاحيات الموقع
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('❌ تم رفض صلاحيات الموقع');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('❌ تم رفض صلاحيات الموقع نهائياً');
        return null;
      }

      // التحقق من تفعيل خدمة الموقع
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('❌ خدمة الموقع معطلة');
        return null;
      }

      // الحصول على الموقع الحالي
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // تحديث العنوان بالإحداثيات الجديدة
      address.latitude = position.latitude;
      address.longitude = position.longitude;

      print('✅ تم إصلاح العنوان: ${address.description} (lat: ${address.latitude}, lng: ${address.longitude})');
      return address;
    } catch (e) {
      print('❌ خطأ في إصلاح العنوان: $e');
      return null;
    }
  }

  /// التحقق من صحة العنوان
  static bool isAddressValid(Address address) {
    return address.latitude != null && 
           address.longitude != null && 
           address.address != null && 
           address.address!.isNotEmpty;
  }

  /// تنظيف العناوين المحفوظة
  static Future<void> cleanupSavedAddresses() async {
    final prefs = await SharedPreferences.getInstance();
    
    // تنظيف saved_address
    String? savedAddress = prefs.getString('saved_address');
    if (savedAddress != null) {
      try {
        Address address = Address.fromJson(jsonDecode(savedAddress));
        if (!isAddressValid(address)) {
          await prefs.remove('saved_address');
          print('🗑️ تم حذف العنوان المحفوظ المعطوب');
        }
      } catch (e) {
        await prefs.remove('saved_address');
        print('🗑️ تم حذف العنوان المحفوظ المعطوب (خطأ في الترميز)');
      }
    }

    // تنظيف selected_address
    String? selectedAddress = prefs.getString('selected_address');
    if (selectedAddress != null) {
      try {
        Address address = Address.fromJson(jsonDecode(selectedAddress));
        if (!isAddressValid(address)) {
          await prefs.remove('selected_address');
          print('🗑️ تم حذف العنوان المحدد المعطوب');
        }
      } catch (e) {
        await prefs.remove('selected_address');
        print('🗑️ تم حذف العنوان المحدد المعطوب (خطأ في الترميز)');
      }
    }

    // تنظيف delivery_address
    String? deliveryAddress = prefs.getString('delivery_address');
    if (deliveryAddress != null) {
      try {
        Address address = Address.fromJSON(jsonDecode(deliveryAddress));
        if (!isAddressValid(address)) {
          await prefs.remove('delivery_address');
          print('🗑️ تم حذف عنوان التوصيل المعطوب');
        }
      } catch (e) {
        await prefs.remove('delivery_address');
        print('🗑️ تم حذف عنوان التوصيل المعطوب (خطأ في الترميز)');
      }
    }
  }

  /// الحصول على عنوان صحيح من العناوين المتاحة
  static Address? getValidAddress(List<Address> addresses) {
    for (Address address in addresses) {
      if (isAddressValid(address)) {
        return address;
      }
    }
    return null;
  }

  /// طباعة معلومات العنوان للتشخيص
  static void printAddressInfo(Address address, String label) {
    print('📍 $label:');
    print('   - الوصف: ${address.description}');
    print('   - العنوان: ${address.address}');
    print('   - خط العرض: ${address.latitude}');
    print('   - خط الطول: ${address.longitude}');
    print('   - صحيح: ${isAddressValid(address)}');
  }
} 