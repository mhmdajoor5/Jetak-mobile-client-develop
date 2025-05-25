import 'dart:convert';
import 'dart:io';
import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;

import '../helpers/custom_trace.dart';
import '../helpers/helper.dart';
import '../models/cart.dart';
import '../models/user.dart';
import '../repository/user_repository.dart' as userRepo;

Future<Stream<Cart>> getCart() async {
  final User user = userRepo.currentUser.value;
  final String token = 'api_token=${user.apiToken}&';
  final String url = '${GlobalConfiguration().getValue('api_base_url')}carts?${token}with=food;food.restaurant;extras&search=user_id:${user.id}&searchFields=user_id:=';

  final client = http.Client();
  final streamedRest = await client.send(http.Request('GET', Uri.parse(url)));
  return streamedRest.stream
      .transform(utf8.decoder)
      .transform(json.decoder)
      .map((data) => Helper.getData(data as Map<String, dynamic>?))
      .expand((data) => data as List)
      .map((data) => Cart.fromJSON(data));
}

Future<Stream<int>> getCartCount() async {
  final User user = userRepo.currentUser.value;
  final String token = 'api_token=${user.apiToken}&';
  final String url = '${GlobalConfiguration().getValue('api_base_url')}carts/count?${token}search=user_id:${user.id}&searchFields=user_id:=';

  final client = http.Client();
  final streamedRest = await client.send(http.Request('GET', Uri.parse(url)));
  return streamedRest.stream.transform(utf8.decoder).transform(json.decoder).map((data) => Helper.getIntData(data as Map<String, dynamic>?));
}

Future<Cart> addCart(Cart cart, bool reset) async {
  final User user = userRepo.currentUser.value;
  cart.userId = user.id!;
  final String token = 'api_token=${user.apiToken}';
  final String resetParam = 'reset=${reset ? 1 : 0}';
  final String url = '${GlobalConfiguration().getValue('api_base_url')}carts?$token&$resetParam';

  final client = http.Client();
  final response = await client.post(Uri.parse(url), headers: {HttpHeaders.contentTypeHeader: 'application/json'}, body: json.encode(cart.toMap()));

  try {
    final decoded = json.decode(response.body)['data'] as Map<String, dynamic>;
    return Cart.fromJSON(decoded);
  } catch (e) {
    print(CustomTrace(StackTrace.current, message: e.toString()));
    return Cart();
  }
}

Future<Cart> updateCart(Cart cart) async {
  final User user = userRepo.currentUser.value;
  if (user.apiToken == null) return Cart();

  cart.userId = user.id!;
  final String token = 'api_token=${user.apiToken}';
  final String url = '${GlobalConfiguration().getValue('api_base_url')}carts/${cart.id}?$token';

  final client = http.Client();
  final response = await client.put(Uri.parse(url), headers: {HttpHeaders.contentTypeHeader: 'application/json'}, body: json.encode(cart.toMap()));

  return Cart.fromJSON(json.decode(response.body)['data']);
}

Future<bool> removeCart(Cart cart) async {
  final User user = userRepo.currentUser.value;
  if (user.apiToken == null) return false;

  final String token = 'api_token=${user.apiToken}';
  final String url = '${GlobalConfiguration().getValue('api_base_url')}carts/${cart.id}?$token';

  final client = http.Client();
  final response = await client.delete(Uri.parse(url), headers: {HttpHeaders.contentTypeHeader: 'application/json'});

  return Helper.getBoolData(json.decode(response.body));
}
