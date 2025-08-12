import 'dart:convert';

import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;

import '../models/cuisine.dart';
import '../models/restaurant.dart';

class CuisineDetails {
  final Cuisine cuisine;
  final List<Restaurant> restaurants;

  CuisineDetails({
    required this.cuisine,
    required this.restaurants,
  });
}

Future<CuisineDetails> getCuisineDetails(String cuisineId) async {
  print("mElkerm Start to fetch cuisine details for ID: $cuisineId");
  try {
    final response = await http.get(
      Uri.parse('${GlobalConfiguration().getValue('api_base_url')}cuisines/$cuisineId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      print("mElkerm Cuisine details response: ${response.body}");
      final decoded = json.decode(response.body);
      final data = decoded['data'];
      
      // Parse cuisine
      final cuisine = Cuisine.fromJSON(data);
      
      // Parse restaurants
      final List<dynamic> restaurantsData = data['restaurants'] ?? [];
      final restaurants = restaurantsData.map((item) => Restaurant.fromJSON(item)).toList();
      
      print("mElkerm Found ${restaurants.length} restaurants for cuisine ${cuisine.name}");
      
      return CuisineDetails(
        cuisine: cuisine,
        restaurants: restaurants,
      );

    } else {
      print("mElkerm Error loading cuisine details: ${response.statusCode}");
      throw Exception('Failed to load cuisine details');
    }
  } catch (err) {
    throw Exception('Error: $err');
  }
} 