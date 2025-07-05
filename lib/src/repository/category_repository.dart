import 'dart:convert';

import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/custom_trace.dart';
import '../helpers/helper.dart';
import '../models/category.dart';
import '../models/filter.dart';

Future<Stream<Category>> getCategories() async {
  Uri uri = Helper.getUri('api/categories');
  Map<String, dynamic> _queryParams = {};
  SharedPreferences prefs = await SharedPreferences.getInstance();
  Filter filter = Filter.fromJSON(json.decode(prefs.getString('filter') ?? '{}'));
  filter.delivery = false;
  filter.open = false;

  _queryParams.addAll(filter.toQuery());
  uri = uri.replace(queryParameters: _queryParams);
  try {
    final client = new http.Client();
    final streamedRest = await client.send(http.Request('get', uri));

    return streamedRest.stream
        .transform(utf8.decoder)
        .transform(json.decoder)
        .map((data) => Helper.getData(data as Map<String, dynamic>?))
        .expand((data) => (data as List))
        .map((data) => Category.fromJSON(data));
  } catch (e) {
    print(CustomTrace(StackTrace.current, message: uri.toString()).toString());
    return new Stream.value(new Category.fromJSON({}));
  }
}

// Future<List<Category>> getCategoriesOfRestaurant1(String restaurantId) async {
//   Uri uri = Helper.getUri('api/categories');
//   Map<String, dynamic> _queryParams = {'restaurant_id': restaurantId};
//
//   uri = uri.replace(queryParameters: _queryParams);
//
//   final response = await http.get(uri);
//   if (response.statusCode == 200) {
//     print('mElkerm get Categories Response status: ${response.statusCode}');
//     // final List<dynamic> data = json.decode(response.body);
//     // return data.map((item) => Category.fromJSON(item)).toList();
//     final data = json.decode(response.body);
//     final result = Helper.getData(data as Map<String, dynamic>?);
//
//     return (result as List)
//         .map((item) => Category.fromJSON(item))
//         .toList();
//   } else {
//     throw Exception('Failed to load categories');
//   }
// }

Future<List<Category>> getCategoriesOfRestaurant(String restaurantId) async {
  try {
    final response = await http.get(
      Uri.parse('${GlobalConfiguration().getValue('api_base_url')}restaurants/$restaurantId/categories-meals'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {

      print('mElkerm get Categories Response status REPOOOO SUCCESS: ${response.statusCode}');
      // final List<dynamic> data = json.decode(response.body);
      final Map<String, dynamic> decodedData = json.decode(response.body);
      final List<dynamic> data = decodedData['categories']['data']; //
      print( 'mElkerm get Categories Response data: ${data.length}');
      return data.map((json) => Category.fromJSON(json)).toList();
    } else {
      print('mElkerm get Categories Response status REPOOOO ERROR: ${response.statusCode}');
      throw Exception('Failed to load restaurants');
    }
  } catch (e) {
    throw Exception('Error: $e');
  }
}

Future<Stream<Category>> getCategory(String id) async {
  final String url = '${GlobalConfiguration().getValue('api_base_url')}categories/$id';
  try {
    final client = new http.Client();
    final streamedRest = await client.send(http.Request('get', Uri.parse(url)));

    return streamedRest.stream.transform(utf8.decoder).transform(json.decoder).map((data) => Helper.getData(data as Map<String, dynamic>?)).map((data) => Category.fromJSON(data));
  } catch (e) {
    print(CustomTrace(StackTrace.current, message: url).toString());
    return new Stream.value(new Category.fromJSON({}));
  }
}
