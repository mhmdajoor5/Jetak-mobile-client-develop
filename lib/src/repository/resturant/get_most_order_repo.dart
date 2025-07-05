import 'dart:convert';

import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;

import '../../models/food.dart';
import '../../models/resturant/most_order_model.dart';

Future<List<MostOrderModel>> getMostOrder({required String restID}) async {
  print("mElkerm ##### Start to fetch the trending foods for home page in the repository");
  try {
    final response = await http.get(
      Uri.parse('${GlobalConfiguration().getValue('api_base_url')}restaurants/${restID}/most-ordered-foods'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      print("mElkerm ##### 00 : Most Popular Food in the repository: ${response.body}");
      final List<dynamic> data = json.decode(response.body);
      print("mElkerm ##### 11 : Most Popular Food in the repository: ${data.length} items found.");

      return data.map((item) => MostOrderModel.fromJson(item)).toList();
    } else {
      print("mElkerm ##### Error loading get popular food : in repo ${response.statusCode}");
      throw Exception('Failed to load most ordered foods: ${response.statusCode}');
    }
  } catch(err) {
    print("mElkerm ##### Error in getMostOrder: $err");
    throw Exception('Error: $err');
  }
}