// import 'dart:convert';
// import 'dart:io';
//
// import 'package:global_configuration/global_configuration.dart';
// import 'package:http/http.dart' as http;
//
// import '../../helpers/custom_trace.dart';
// import '../../models/resturant/resturant_details_model.dart';
//
// Future<RestaurantDetailsModel?> getRestaurantDetails(int restaurantId) async {
//   // final String url = '${GlobalConfiguration().getValue('api_base_url')}carts?$token&$resetParam';
//   final String url =
//       '${GlobalConfiguration().getValue('api_base_url')}restaurants/$restaurantId/categories-meals';
//
//   print("mElkerm get details url: $url");
//   final client = http.Client();
//   final response = await client.post(
//     Uri.parse(url),
//     headers: {HttpHeaders.contentTypeHeader: 'application/json'},
//   );
//
//   try {
//     final decoded = json.decode(response.body) as Map<String, dynamic>;
//     print("mElkerm get details success");
//     return RestaurantDetailsModel.fromJson(decoded);
//   } catch (e) {
//     print("mElkerm get details Error");
//     print(CustomTrace(StackTrace.current, message: e.toString()));
//   }
// }
