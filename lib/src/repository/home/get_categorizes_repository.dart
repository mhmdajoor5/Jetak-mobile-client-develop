// Future<List<Category>> getCategories() async {
//   final Uri uri = Uri.parse('https://your.api/categories');
//
//   final client = new http.Client();
//   final response = await client.get(uri, headers: {
//     'Content-Type': 'application/json',
//   });
//
//   final data = json.decode(response.body)['data'];
//   return (data as List).map((item) => Category.fromJSON(item)).toList();
// }

import 'dart:convert';

import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;

import '../../models/category.dart';

Future<List<Category>> getCategories() async {
  print("mElkerm Strart to fetch the categories in the repository");
  try{
    final response = await http.get(
      Uri.parse('${GlobalConfiguration().getValue('api_base_url')}categories'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      print( "mElkerm 00 : get the Categories in the repository: ${response.body}");
      final decoded = json.decode(response.body);
      print("mElkerm 11 : get the Categories in the repository: ${decoded['data'].length} items found.");
      final List<dynamic> data = decoded['data'];
      print("mElkerm 22 : get the Categories in the repository: ${data.length} items found.");

      print("mElkerm get the Categories in the repository");
      return data.map((item) => Category.fromJSON(item)).toList();

    } else {
      print("mElkerm Error loading Categories: in repo ${response.statusCode}");
      throw Exception('Failed to load slides');
    }
  }catch(err) {
    throw Exception('Error: $err');
  }

}