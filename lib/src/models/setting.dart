import 'package:flutter/material.dart';
import '../helpers/custom_trace.dart';

class Setting {
  String appName = '';
  // Backend-controlled app availability status: '1' = available, '0' = maintenance/off
  String appStatus = '1';
  double defaultTax = 0.0;
  String defaultCurrency = '';
  String distanceUnit = 'km';
  bool currencyRight = false;
  int currencyDecimalDigits = 2;
  bool payPalEnabled = true;
  bool stripeEnabled = true;
  bool razorPayEnabled = true;
  String mainColor = '';
  String mainDarkColor = '';
  String secondColor = '';
  String secondDarkColor = '';
  String accentColor = '';
  String accentDarkColor = '';
  String scaffoldDarkColor = '';
  String scaffoldColor = '';
  String googleMapsKey = '';
  String fcmKey = '';
  ValueNotifier<Locale> mobileLanguage = ValueNotifier(Locale('en', ''));
  String appVersion = '';
  bool enableVersion = true;
  List<String> homeSections = [];

  ValueNotifier<Brightness> brightness = ValueNotifier(Brightness.light);

  Setting();

  factory Setting.fromJSON(Map<String, dynamic>? jsonMap) {
    final setting = Setting();
    try {
      setting.appName = jsonMap?['app_name']?.toString() ?? '';
      setting.appStatus = jsonMap?['app_status']?.toString() ?? '1';
      setting.mainColor = jsonMap?['main_color']?.toString() ?? '';
      setting.mainDarkColor = jsonMap?['main_dark_color']?.toString() ?? '';
      setting.secondColor = jsonMap?['second_color']?.toString() ?? '';
      setting.secondDarkColor = jsonMap?['second_dark_color']?.toString() ?? '';
      setting.accentColor = jsonMap?['accent_color']?.toString() ?? '';
      setting.accentDarkColor = jsonMap?['accent_dark_color']?.toString() ?? '';
      setting.scaffoldDarkColor = jsonMap?['scaffold_dark_color']?.toString() ?? '';
      setting.scaffoldColor = jsonMap?['scaffold_color']?.toString() ?? '';
      setting.googleMapsKey = jsonMap?['google_maps_key']?.toString() ?? '';
      setting.fcmKey = jsonMap?['fcm_key']?.toString() ?? '';
      setting.mobileLanguage.value = Locale(jsonMap?['mobile_language']?.toString() ?? 'en', '');
      setting.appVersion = jsonMap?['app_version']?.toString() ?? '';
      setting.distanceUnit = jsonMap?['distance_unit']?.toString() ?? 'km';
      setting.enableVersion = jsonMap?['enable_version'] == '1';
      setting.defaultTax = double.tryParse(jsonMap?['default_tax']?.toString() ?? '0') ?? 0.0;
      setting.defaultCurrency = jsonMap?['default_currency']?.toString() ?? '';
      setting.currencyDecimalDigits = int.tryParse(jsonMap?['default_currency_decimal_digits']?.toString() ?? '2') ?? 2;
      setting.currencyRight = jsonMap?['currency_right'] == '1';
      setting.payPalEnabled = jsonMap?['enable_paypal'] == '1';
      setting.stripeEnabled = jsonMap?['enable_stripe'] == '1';
      setting.razorPayEnabled = jsonMap?['enable_razorpay'] == '1';

      for (int i = 1; i <= 14; i++) {
        final section = jsonMap?['home_section_$i']?.toString() ?? 'empty';
        setting.homeSections.add(section);
      }
    } catch (e) {
      print(CustomTrace(StackTrace.current, message: e.toString()));
    }
    return setting;
  }

  Map<String, dynamic> toMap() {
    return {
      "app_name": appName,
      "default_tax": defaultTax,
      "default_currency": defaultCurrency,
      "default_currency_decimal_digits": currencyDecimalDigits,
      "currency_right": currencyRight,
      "enable_paypal": payPalEnabled,
      "enable_stripe": stripeEnabled,
      "enable_razorpay": razorPayEnabled,
      "mobile_language": mobileLanguage.value.languageCode,
    };
  }
}
