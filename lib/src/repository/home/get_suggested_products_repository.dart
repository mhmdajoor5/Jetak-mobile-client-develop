import 'dart:convert';

import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;

import '../../models/food.dart';

Future<List<Food>> getSuggestedProducts() async {
  print("mElkerm Start to fetch the suggested products in the repository");
  try {
    String url = '${GlobalConfiguration().getValue('api_base_url')}suggested';

    final response = await http.get(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      print("mElkerm 00 : get the suggested products in the repository: ${response.body}");
      final decoded = json.decode(response.body);
      
      if (decoded['success'] == true && decoded['data'] != null) {
        // تحقق من تخطيط البيانات
        print("mElkerm Debug: Full API response structure: ${decoded.keys}");
        print("mElkerm Debug: Data structure: ${decoded['data'].keys}");
        
        final List<dynamic> data = decoded['data']['data'] ?? [];
        print("mElkerm 11 : get the suggested products in the repository: ${data.length} items found.");
        
        if (data.isNotEmpty) {
          print("mElkerm Debug: First item structure: ${data[0].keys}");
        }
        
        final products = data.map((item) => Food.fromJSON(item)).toList();
        print("mElkerm Debug: Repository - Parsed ${products.length} suggested products");
        return products;
      } else {
        print("mElkerm Error: API returned success=false or no data");
        print("mElkerm Debug: API response: $decoded");
        return [];
      }
    } else {
      print("mElkerm Error loading suggested products: in repo ${response.statusCode}");
      throw Exception('Failed to load suggested products');
    }
  } catch (err) {
    print("mElkerm Exception in getSuggestedProducts: $err");
    throw Exception('Error: $err');
  }
}
