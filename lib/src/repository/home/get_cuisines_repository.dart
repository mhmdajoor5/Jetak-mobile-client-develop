import 'dart:convert';

import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;

import '../../models/cuisine.dart';

Future<List<Cuisine>> getCuisines() async {
  print("mElkerm Start to fetch the cuisines in the repository");
  try {
    final response = await http.get(
      Uri.parse('${GlobalConfiguration().getValue('api_base_url')}cuisines'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      print("mElkerm 00 : get the Cuisines in the repository: ${response.body}");
      final decoded = json.decode(response.body);
      print("mElkerm 11 : get the Cuisines in the repository: ${decoded['data'].length} items found.");
      final List<dynamic> data = decoded['data'];
      print("mElkerm 22 : get the Cuisines in the repository: ${data.length} items found.");

      print("mElkerm get the Cuisines in the repository");
      return data.map((item) => Cuisine.fromJSON(item)).toList();

    } else {
      print("mElkerm Error loading Cuisines: in repo ${response.statusCode}");
      throw Exception('Failed to load cuisines');
    }
  } catch (err) {
    throw Exception('Error: $err');
  }
} 