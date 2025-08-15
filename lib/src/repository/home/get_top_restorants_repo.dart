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
    // Build URI with query params
    final baseUrl = GlobalConfiguration().getValue('api_base_url');
    final uri = Uri.parse('${baseUrl}restaurants').replace(queryParameters: {
      'offers': 'true',
      'limit': '50',
    });

    final response = await http
        .get(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Cache-Control': 'no-cache',
            'Connection': 'keep-alive',
          },
        )
        .timeout(Duration(seconds: 4));

    if (response.statusCode == 200) {
      print( "mElkerm 555 00 : get the Top Restaurants in the repository: ${response.body}");
      final decoded = json.decode(response.body);
      final dynamic inner = decoded['data'];
      final List<dynamic> data =
          inner is Map<String, dynamic> && inner['data'] is List
              ? (inner['data'] as List)
              : inner is List
                  ? inner
                  : <dynamic>[];

      print("mElkerm 555 22 : get the Top Restaurants in the repository: ${data.length} items found.");

      // Parse restaurants
      List<Restaurant> restaurants = data.map((item) => Restaurant.fromJSON(item)).toList();

      // Ensure they actually have an offer (best_discount exists)
      restaurants = restaurants.where((r) => r.coupon != null && r.coupon!.valid).toList();

      // Sort by latest updated or keep original order if not available
      // (Removed distance/proximity sorting to rely solely on offers)
      print("mElkerm 555 get the Top Restaurants in the repository (offers only): ${restaurants.length} filtered with offers");
      return restaurants;
    } else {
      print("mElkerm 555 Error loading Top Restaurants: in repo ${response.statusCode}");
      throw Exception('Failed to load restaurants');
    }
  } catch (e) {
    throw Exception('Error: $e');
  }
}