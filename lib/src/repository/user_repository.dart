import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../helpers/helper.dart';
import '../models/address.dart';
import '../models/credit_card.dart';
import '../models/user.dart' as userModel;

ValueNotifier<userModel.User> currentUser = ValueNotifier(userModel.User());

// دالة التحقق من صحة العنوان
String? validateAddress(Address address) {
  // التحقق من وجود العنوان
  if (address.address == null || address.address!.trim().isEmpty) {
    return 'العنوان مطلوب';
  }
  
  // التحقق من طول العنوان
  if (address.address!.trim().length < 10) {
    return 'العنوان يجب أن يكون 10 أحرف على الأقل';
  }
  
  // التحقق من وجود الإحداثيات
  if (address.latitude == null || address.longitude == null) {
    return 'إحداثيات الموقع مطلوبة';
  }
  
  // التحقق من صحة الإحداثيات
  if (address.latitude! < -90 || address.latitude! > 90) {
    return 'خط العرض غير صحيح';
  }
  
  if (address.longitude! < -180 || address.longitude! > 180) {
    return 'خط الطول غير صحيح';
  }
  
  // التحقق من وجود وصف العنوان
  if (address.description == null || address.description!.trim().isEmpty) {
    return 'وصف العنوان مطلوب';
  }
  
  // التحقق من طول وصف العنوان
  if (address.description!.trim().length < 3) {
    return 'وصف العنوان يجب أن يكون 3 أحرف على الأقل';
  }
  
  return null; // العنوان صحيح
}

Future<userModel.User> login(userModel.User user) async {
  final String url = '${GlobalConfiguration().getValue('api_base_url')}login';
  final client = http.Client();
  final response = await client.post(
    Uri.parse(url),
    headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    body: json.encode(user.toMap()),
  );
  if (response.statusCode == 200) {
    setCurrentUser(response.body);
    currentUser.value =
        userModel.User.fromJSON(json.decode(response.body)['data']);
  } else {
    throw Exception(response.body);
  }
  return currentUser.value;
}

Future<userModel.User> sendOTP(String phone) async {
  if (currentUser.value.apiToken == null) {
    throw Exception("User not authenticated");
  }

  final String url = '${GlobalConfiguration().getValue('api_base_url')}send-sms';
  final client = http.Client();
  final response = await client.post(
    Uri.parse(url),
    headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    body: json.encode({
      "api_token": currentUser.value.apiToken,
      "phone": phone,
    }),
  );
  if (response.statusCode == 200) {
    setCurrentUser(response.body);
    currentUser.value =
        userModel.User.fromJSON(json.decode(response.body)['data']);
  } else {
    throw Exception(response.body);
  }
  return currentUser.value;
}

Future<bool> verifyOTP(String otp) async {
  if (currentUser.value.apiToken == null) {
    throw Exception("User not authenticated");
  }

  final String url = '${GlobalConfiguration().getValue('api_base_url')}submit-otp';
  final client = http.Client();
  final response = await client.post(
    Uri.parse(url),
    headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    body: json.encode({
      "api_token": currentUser.value.apiToken,
      "code": otp
    }),
  );
  if (response.statusCode == 200) {
    setCurrentUser(response.body);
    currentUser.value =
        userModel.User.fromJSON(json.decode(response.body)['data']);
  } else {
    throw Exception(response.body);
  }
  return currentUser.value.verifiedPhone ?? false;
}

Future<userModel.User> register(userModel.User user) async {
  final String url = '${GlobalConfiguration().getValue('api_base_url')}register';
  final client = http.Client();
  final response = await client.post(
    Uri.parse(url),
    headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    body: json.encode(user.toMap()),
  );
  if (response.statusCode == 200) {
    setCurrentUser(response.body);
    currentUser.value =
        userModel.User.fromJSON(json.decode(response.body)['data']);
  } else {
    throw Exception(response.body);
  }
  return currentUser.value;
}

Future<bool> resetPassword(userModel.User user) async {
  final String url = '${GlobalConfiguration().getValue('api_base_url')}send_reset_link_email';
  final client = http.Client();
  final response = await client.post(
    Uri.parse(url),
    headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    body: json.encode(user.toMap()),
  );
  if (response.statusCode == 200) {
    return true;
  } else {
    throw Exception(response.body);
  }
}

Future<void> logout() async {
  currentUser.value = userModel.User();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.remove('current_user');
  await prefs.remove('credit_card');
  Helper.clearSavedCards();
}

Future<void> setCurrentUser(String jsonString) async {
  if (json.decode(jsonString)['data'] != null) {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'current_user', json.encode(json.decode(jsonString)['data']));
  }
}

Future<void> saveCurrentUser(String jsonString) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('current_user', jsonString);
  currentUser.value = userModel.User.fromJSON(json.decode(jsonString)['data']);
  currentUser.notifyListeners();
}

Future<void> setCreditCard(CreditCard creditCard) async {
  // يمكنك تفعيل التخزين عند الحاجة
  // SharedPreferences prefs = await SharedPreferences.getInstance();
  // await prefs.setString('credit_card', json.encode(creditCard.toMap()));
}

Future<userModel.User> getCurrentUser() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  if ((currentUser.value.auth == null || currentUser.value.auth == false) && prefs.containsKey('current_user')) {
    String storedCurrentUser = prefs.getString('current_user')!;
    currentUser.value =
        userModel.User.fromJSON(json.decode(storedCurrentUser));
    currentUser.value.auth = true;
  } else if (!prefs.containsKey('current_user')) {
    currentUser.value.auth = false;
  }
  currentUser.notifyListeners();
  return currentUser.value;
}

Future<CreditCard> getCreditCard() async {
  CreditCard _creditCard = CreditCard();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  if (prefs.containsKey('credit_card')) {
    String storedCreditCard = prefs.getString('credit_card')!;
    _creditCard = CreditCard.fromJSON(json.decode(storedCreditCard));
  }
  return _creditCard;
}

Future<userModel.User> update(userModel.User user) async {
  if (currentUser.value.apiToken == null) {
    throw Exception("User not authenticated");
  }

  final String _apiToken = 'api_token=${currentUser.value.apiToken}';
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}users/${currentUser.value.id}?$_apiToken';
  final client = http.Client();
  final response = await client.post(
    Uri.parse(url),
    headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    body: json.encode(user.toMap()),
  );
  setCurrentUser(response.body);
  currentUser.value =
      userModel.User.fromJSON(json.decode(response.body)['data']);
  return currentUser.value;
}

Future<Stream<Address>> getAddresses() async {
  userModel.User _user = currentUser.value;
  if (_user.apiToken == null) {
    throw Exception("User not authenticated");
  }

  final String _apiToken = 'api_token=${_user.apiToken}&';
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}delivery_addresses?${_apiToken}search=user_id:${_user.id}&searchFields=user_id:=&orderBy=updated_at&sortedBy=desc';

  final client = http.Client();
  final streamedRest = await client.send(http.Request('get', Uri.parse(url)));

  return streamedRest.stream
      .transform(utf8.decoder)
      .transform(json.decoder)
      .map((data) => Helper.getData(data as Map<String, dynamic>?))
      .expand((data) => (data as List))
      .map((data) => Address.fromJSON(data));
}

Future<Address> addAddress(Address address) async {
  userModel.User _user = currentUser.value;
  if (_user.apiToken == null) {
    throw Exception("User not authenticated");
  }

  // التحقق من صحة العنوان قبل الإرسال
  String? validationError = validateAddress(address);
  if (validationError != null) {
    throw Exception(validationError);
  }

  final String _apiToken = 'api_token=${_user.apiToken}';
  address.userId = _user.id!;
  
  // طباعة بيانات العنوان قبل الإرسال
  print('📍 بيانات العنوان المرسلة:');
  print('- address: ${address.address}');
  print('- latitude: ${address.latitude}');
  print('- longitude: ${address.longitude}');
  print('- description: ${address.description}');
  print('- type: ${address.type}');
  print('- entryMethod: ${address.entryMethod}');
  print('- instructions: ${address.instructions}');
  print('- label: ${address.label}');
  
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}delivery_addresses?$_apiToken';
  final client = http.Client();
  final addressMap = address.toMap();
  final requestBody = json.encode(addressMap);
  print('📤 البيانات المرسلة إلى API: $requestBody');
  print('📤 خريطة العنوان: $addressMap');
  
  final response = await client.post(
    Uri.parse(url),
    headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    body: requestBody,
  );

  print('📥 Response body: ${response.body}');

  final Map<String, dynamic> jsonResponse = json.decode(response.body);

  if (jsonResponse['data'] == null) {
    throw Exception('Response JSON does not contain "data" or it is null');
  }

  final addedAddress = Address.fromJSON(jsonResponse['data']);
  print('✅ العنوان المُضاف من API يحتوي على الإحداثيات: lat=${addedAddress.latitude}, lng=${addedAddress.longitude}');
  
  return addedAddress;
}


Future<Address> updateAddress(Address address) async {
  userModel.User _user = currentUser.value;
  if (_user.apiToken == null) {
    throw Exception("User not authenticated");
  }

  // التحقق من صحة العنوان قبل الإرسال
  String? validationError = validateAddress(address);
  if (validationError != null) {
    throw Exception(validationError);
  }

  final String _apiToken = 'api_token=${_user.apiToken}';
  address.userId = _user.id!;
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}delivery_addresses/${address.id}?$_apiToken';
  final client = http.Client();
  final response = await client.put(
    Uri.parse(url),
    headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    body: json.encode(address.toMap()),
  );
  return Address.fromJSON(json.decode(response.body)['data']);
}

Future<Address> removeDeliveryAddress(Address address) async {
  userModel.User _user = currentUser.value;
  if (_user.apiToken == null) {
    throw Exception("User not authenticated");
  }

  final String _apiToken = 'api_token=${_user.apiToken}';
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}delivery_addresses/${address.id}?$_apiToken';
  final client = http.Client();
  final response = await client.delete(
    Uri.parse(url),
    headers: {HttpHeaders.contentTypeHeader: 'application/json'},
  );
  return Address.fromJSON(json.decode(response.body)['data']);
}
