import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/custom_trace.dart';
import '../helpers/maps_util.dart';
import '../models/address.dart';
import '../models/coupon.dart';
import '../models/setting.dart';

ValueNotifier<Setting> setting = new ValueNotifier(new Setting());
ValueNotifier<Address> deliveryAddress = new ValueNotifier(new Address());
Coupon coupon = new Coupon.fromJSON({});
final navigatorKey = GlobalKey<NavigatorState>();

Future<Setting> initSettings() async {
  Setting _setting;
  final String url = '${GlobalConfiguration().getValue('api_base_url')}settings';
  try {
    final response = await http.get(Uri.parse(url), headers: {HttpHeaders.contentTypeHeader: 'application/json'});
    if (response.statusCode == 200 && response.headers.containsValue('application/json')) {
      if (json.decode(response.body)['data'] != null) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('settings', json.encode(json.decode(response.body)['data']));
        _setting = Setting.fromJSON(json.decode(response.body)['data']);
        if (prefs.containsKey('language')) {
          String langCode = await prefs.getString('language')!;
          _setting.mobileLanguage.value = Locale(langCode, '');
        }
        _setting.brightness.value = prefs.getBool('isDark') ?? false ? Brightness.dark : Brightness.light;
        setting.value = _setting;
        // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
        setting.notifyListeners();
      }
    } else {
      print(CustomTrace(StackTrace.current, message: response.body).toString());
    }
  } catch (e) {
    print(CustomTrace(StackTrace.current, message: url).toString());
    return Setting.fromJSON({});
  }
  return setting.value;
}

Future<dynamic> setCurrentLocation() async {
  var location = new Location();
  MapsUtil mapsUtil = new MapsUtil();
  final whenDone = new Completer();
  Address _address = new Address();
  
  try {
    location.requestService().then((value) async {
      location.getLocation().then((_locationData) async {
        // التحقق من وجود الإحداثيات
        if (_locationData.latitude == null || _locationData.longitude == null) {
          print('❌ فشل في الحصول على إحداثيات الموقع');
          whenDone.complete(_address);
          return;
        }
        
        String? _addressName = await mapsUtil.getAddressName(
          LatLng(_locationData.latitude!, _locationData.longitude!), 
          setting.value.googleMapsKey
        );
        
        _address = Address.fromJSON({
          'address': _addressName, 
          'latitude': _locationData.latitude, 
          'longitude': _locationData.longitude
        });
        
        print('📍 تم الحصول على الموقع الحالي: ${_address.address} (lat: ${_address.latitude}, lng: ${_address.longitude})');
        
        await changeCurrentLocation(_address);
        whenDone.complete(_address);
      }).timeout(Duration(seconds: 10), onTimeout: () async {
        print('⏰ انتهت مهلة الحصول على الموقع');
        await changeCurrentLocation(_address);
        whenDone.complete(_address);
        return null;
      }).catchError((e) {
        print('❌ خطأ في الحصول على الموقع: $e');
        whenDone.complete(_address);
      });
    });
  } catch (e) {
    print('❌ خطأ في طلب خدمة الموقع: $e');
    whenDone.complete(_address);
  }
  
  return whenDone.future;
}

Future<Address> changeCurrentLocation(Address _address) async {
  if (!_address.isUnknown()) {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('delivery_address', json.encode(_address.toMap()));
    print('✅ تم حفظ العنوان في الإعدادات: ${_address.address} (lat: ${_address.latitude}, lng: ${_address.longitude})');
  } else {
    print('⚠️ تحذير: محاولة حفظ عنوان بدون إحداثيات في الإعدادات');
  }
  return _address;
}

Future<Address> getCurrentLocation() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  //await prefs.clear();
  if (prefs.containsKey('delivery_address')) {
    String storedDeliveryAddress = await prefs.getString('delivery_address')!;
    deliveryAddress.value = Address.fromJSON(json.decode(storedDeliveryAddress));
    
    // التحقق من وجود الإحداثيات
    if (deliveryAddress.value.latitude == null || deliveryAddress.value.longitude == null) {
      print('⚠️ العنوان المحفوظ في الإعدادات لا يحتوي على إحداثيات صحيحة');
      // إعادة تعيين عنوان فارغ
      deliveryAddress.value = Address.fromJSON({});
      return deliveryAddress.value;
    }
    
    print('✅ تم تحميل العنوان من الإعدادات: ${deliveryAddress.value.address} (lat: ${deliveryAddress.value.latitude}, lng: ${deliveryAddress.value.longitude})');
    return deliveryAddress.value;
  } else {
    deliveryAddress.value = Address.fromJSON({});
    print('❌ لا يوجد عنوان محفوظ في الإعدادات');
    return deliveryAddress.value;
  }
}

void setBrightness(Brightness brightness) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  if (brightness == Brightness.dark) {
    prefs.setBool("isDark", true);
    brightness = Brightness.dark;
  } else {
    prefs.setBool("isDark", false);
    brightness = Brightness.light;
  }
}

Future<void> setDefaultLanguage(String language) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('language', language);
}

Future<String> getDefaultLanguage(String defaultLanguage) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  if (prefs.containsKey('language')) {
    defaultLanguage = await prefs.getString('language')!;
  }
  return defaultLanguage;
}

Future<void> saveMessageId(String messageId) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('google.message_id', messageId);
}

Future<String> getMessageId() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return await prefs.getString('google.message_id')!;
}
