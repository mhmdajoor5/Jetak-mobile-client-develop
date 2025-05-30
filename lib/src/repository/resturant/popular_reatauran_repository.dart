import 'dart:convert';

import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;

import '../../models/restaurant.dart';


/// mElkerm : This function fetches popular restaurants from the API. {Repo}
Future<List<Restaurant>> fetchPopularRestaurants() async {
  try {
    final response = await http.get(
      ///'${GlobalConfiguration().getValue('api_base_url')}carts?$token&$resetParam'
      Uri.parse('${GlobalConfiguration().getValue('api_base_url')}restaurants?popular=true'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      // final List<dynamic> data = json.decode(response.body);
      final Map<String, dynamic> decodedData = json.decode(response.body);
      final List<dynamic> data = decodedData['data']['data']; //

      return data.map((json) => Restaurant.fromJSON(json)).toList();
    } else {
      throw Exception('Failed to load restaurants');
    }
  } catch (e) {
    throw Exception('Error: $e');
  }
}