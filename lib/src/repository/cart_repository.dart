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
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}carts?${token}with=food;food.restaurant;extras&search=user_id:${user.id}&searchFields=user_id:=';

  print('🔍 getCart ▶ URL: $url');

  final client = http.Client();
  final request = http.Request('GET', Uri.parse(url));
  final streamedRest = await client.send(request);

  print('🔍 getCart ▶ Response status code: ${streamedRest.statusCode}');

  if (streamedRest.statusCode == 200) {
    // Collect the full body for debug print
    final responseBody = await streamedRest.stream.bytesToString();
    print('🔍 getCart ▶ Response body: $responseBody');

    // الحل هنا: تحويل JSON مباشرة إلى List من Cart
    final List<dynamic> decodedJson = json.decode(responseBody);
    final stream = Stream.fromIterable(decodedJson.map((e) => Cart.fromJSON(e)));

    return stream;
  } else {
    print('❌ getCart ▶ Non-200 response, status: ${streamedRest.statusCode}');
    return Stream<Cart>.empty();
  }
}

// Future<Stream<int>> getCartCount() async {
//   print("mElkerm start to fetch the cart data");
//   final User user = userRepo.currentUser.value;
//   final String token = 'api_token=${user.apiToken}&';
//   final String url =
//       '${GlobalConfiguration().getValue('api_base_url')}carts/count?${token}search=user_id:${user.id}&searchFields=user_id:=';
//
//   final client = http.Client();
//   final streamedRest = await client
//       .send(http.Request('GET', Uri.parse(url)))
//       .then((value) {
//         print("mElkerm Fetch the data success ${value.stream}");
//       });
//   return streamedRest.stream
//       .transform(utf8.decoder)
//       .transform(json.decoder)
//       .map((data) => Helper.getIntData(data as Map<String, dynamic>?));
// }

Future<Stream<int>> getCartCount() async {
  print("mElkerm start to fetch the cart data");
  final User user = userRepo.currentUser.value;
  final String token = 'api_token=${user.apiToken}&';
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}carts/count?${token}search=user_id:${user.id}&searchFields=user_id:=';

  final client = http.Client();
  final streamedRest = await client.send(http.Request('GET', Uri.parse(url)));

  print("mElkerm Fetch the data success with status ${streamedRest.statusCode}");

  if (streamedRest.statusCode == 200) {
    return streamedRest.stream
        .transform(utf8.decoder)
        .transform(json.decoder)
        .map((data) => Helper.getIntData(data as Map<String, dynamic>?));
  } else {
    print('❌ getCartCount ▶ Non-200 response, status: ${streamedRest.statusCode}');
    return Stream<int>.empty();
  }
}


Future<Cart> addCart(Cart cart, bool reset) async {
  final User user = userRepo.currentUser.value;
  cart.userId = user.id!;
  final String token = 'api_token=${user.apiToken}';
  final String resetParam = 'reset=${reset ? 1 : 0}';
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}carts?$token&$resetParam';

  final client = http.Client();
  final response = await client.post(
    Uri.parse(url),
    headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    body: json.encode(cart.toMap()),
  );

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
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}carts/${cart.id}?$token';

  final client = http.Client();
  final response = await client.put(
    Uri.parse(url),
    headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    body: json.encode(cart.toMap()),
  );

  return Cart.fromJSON(json.decode(response.body)['data']);
}

Future<bool> removeCart(Cart cart) async {
  final User user = userRepo.currentUser.value;

  if (user.apiToken == null) {
    print('❌ removeCart ▶ No API token found for user. Aborting.');
    return false;
  }

  final String token = 'api_token=${user.apiToken}';
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}carts/${cart.id}?$token';

  print('🔍 removeCart ▶ DELETE URL: $url');

  final client = http.Client();
  try {
    final response = await client.delete(
      Uri.parse(url),
      headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    );

    print('🔍 removeCart ▶ Response status: ${response.statusCode}');
    print('🔍 removeCart ▶ Response body: ${response.body}');

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      final result = Helper.getBoolData(decoded);
      print('✅ removeCart ▶ Parsed result: $result');
      return result;
    } else {
      print('❌ removeCart ▶ Failed with status ${response.statusCode}');
      return false;
    }
  } catch (e) {
    print('❌ removeCart ▶ Error: $e');
    return false;
  } finally {
    client.close();
  }
}
