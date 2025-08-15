import 'dart:convert';

import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;

import '../../models/restaurant.dart';


/// mElkerm : This function fetches popular restaurants from the API. {Repo}
Future<List<Restaurant>> fetchPopularRestaurants() async {
  try {
    final response = await http.get(
      Uri.parse('${GlobalConfiguration().getValue('api_base_url')}restaurants?popular=true'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Cache-Control': 'no-cache',
        'Connection': 'keep-alive',
      },
    ).timeout(Duration(seconds: 8));

    if (response.statusCode == 200) {
      final Map<String, dynamic> decodedData = json.decode(response.body);
      final dynamic inner = decodedData['data'];
      final List<dynamic> data =
          inner is Map<String, dynamic> && inner['data'] is List
              ? (inner['data'] as List)
              : inner is List
                  ? inner
                  : <dynamic>[];
      return data.map((json) => Restaurant.fromJSON(json)).toList();
    } else {
      throw Exception('Failed to load restaurants');
    }
  } catch (e) {
    throw Exception('Error: $e');
  }
}