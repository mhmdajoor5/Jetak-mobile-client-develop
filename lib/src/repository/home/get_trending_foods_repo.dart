import 'dart:convert';

import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;

import '../../models/food.dart';




Future<List<Food>> getTrendingFoods() async {
  print("mElkerm Strart to fetch the trending foods for home page in the repository");
  try{
    final response = await http.get(
      ///    https://carrytechnologies.co/api/foods?trending=week
      Uri.parse('${GlobalConfiguration().getValue('api_base_url')}foods?trending=week'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      print( "mElkerm 00 : trending foods for home pagein the repository: ${response.body}");
      final decoded = json.decode(response.body);
      print("mElkerm 11 : trending foods for home pagein the repository: ${decoded['data'].length} items found.");
      final List<dynamic> data = decoded['data'];
      print("mElkerm 22 : trending foods for home pagein the repository: ${data.length} items found.");

      print("mElkerm gtrending foods for home pagein the repository");
      return data.map((item) => Food.fromJSON(item)).toList();

    } else {
      print("mElkerm Error loading trending foods for home page: in repo ${response.statusCode}");
      throw Exception('Failed to load slides');
    }
  }catch(err) {
    throw Exception('Error: $err');
  }

}