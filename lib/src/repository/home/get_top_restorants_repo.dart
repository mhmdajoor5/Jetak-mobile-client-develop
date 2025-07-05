// Future<List<Restaurant>> getTopRestaurants(Address address) async {
//   final Uri uri = Uri.parse(
//     'https://your.api/near_restaurants?lat=${address.latitude}&lng=${address.longitude}',
//   );
//
//   final client = http.Client();
//   final response = await client.get(uri, headers: {
//     'Content-Type': 'application/json',
//   });
//
//   final data = json.decode(response.body)['data'];
//   return (data as List).map((item) => Restaurant.fromJSON(item)).toList();
// }

import 'dart:convert';

import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;

import '../../models/restaurant.dart';

Future<List<Restaurant>> getTopRestaurants() async {
  print("mElkerm 555 Strart to fetch the Top Restaurants in the repository");
  try {
    final response = await http.get(
      Uri.parse('${GlobalConfiguration().getValue('api_base_url')}restaurants?offers=ture'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Cache-Control': 'no-cache',
        'Connection': 'keep-alive',
      },
    ).timeout(Duration(seconds: 2));

    if (response.statusCode == 200) {
      print( "mElkerm 555 00 : get the Top Restaurants in the repository: ${response.body}");
      final decoded = json.decode(response.body);
      print("mElkerm 555 11 : get the Top Restaurants in the repository: ${decoded['data'].length} items found.");
      final List<dynamic> data = decoded['data']['data'];
      print("mElkerm 555 22 : get the Top Restaurants in the repository: ${data.length} items found.");

      print("mElkerm 555 get the Top Restaurants in the repository");
      return data.map((item) => Restaurant.fromJSON(item)).toList();
    } else {
      print("mElkerm 555 Error loading Top Restaurants: in repo ${response.statusCode}");
      throw Exception('Failed to load restaurants');
    }
  } catch (e) {
    throw Exception('Error: $e');
  }
}