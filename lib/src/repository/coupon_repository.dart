import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/custom_trace.dart';
import '../helpers/helper.dart';
import '../models/coupon.dart';
import '../models/user.dart';
import '../repository/user_repository.dart' as userRepo;

Future<Stream<Coupon>> verifyCoupon(String code) async {
  Uri uri = Helper.getUri('api/coupons');
  User _user = userRepo.currentUser.value;
  Map<String, dynamic> query = {
    'api_token': _user.apiToken,
    'with': 'discountables',
    'search': 'code:$code',
    'searchFields': 'code:=',
  };
  uri = uri.replace(queryParameters: query);
  print(CustomTrace(StackTrace.current, message: uri.toString()).toString());
  try {
    final client = new http.Client();
    final streamedRest = await client.send(http.Request('get', uri));
    return streamedRest.stream.transform(utf8.decoder).transform(json.decoder).map((data) {
      print('🎫 البيانات القادمة من API: $data');
      return Helper.getData(data as Map<String, dynamic>?);
    }).expand((data) {
      print('🎫 البيانات بعد Helper.getData: $data');
      return (data as List);
    }).map((data) {
      print('🎫 إنشاء كوبون من البيانات: $data');
      return Coupon.fromJSON(data);
    });
  } catch (e) {
    print('🎫 خطأ في repository: $e');
    print(CustomTrace(StackTrace.current, message: uri.toString()).toString());
    return new Stream.value(new Coupon.fromJSON({}));
  }
}

Future<Coupon> saveCoupon(Coupon coupon) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('coupon', json.encode(coupon.toMap()));
  return coupon;
}

Future<Coupon> getCoupon() async {
  Coupon _coupon = Coupon.fromJSON({});
  SharedPreferences prefs = await SharedPreferences.getInstance();
  if (prefs.containsKey('coupon')) {
    String? storedCoupon =  await prefs.getString('coupon');
    _coupon = Coupon.fromJSON(json.decode(storedCoupon!));
  }
  return _coupon;
}
