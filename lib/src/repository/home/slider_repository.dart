import 'dart:convert';

import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;

import '../../models/slide.dart';

Future<List<Slide>> getSlides() async {
  print("mElkerm Strart to fetch the slides in the repository");
  try{
    final response = await http.get(
      Uri.parse('${GlobalConfiguration().getValue('api_base_url')}slides'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      print( "mElkerm 00 : get the slides in the repository: ${response.body}");
      final decoded = json.decode(response.body);
      print("mElkerm 11 : get the slides in the repository: ${decoded['data'].length} items found.");
      final List<dynamic> data = decoded['data'];
      print("mElkerm 22 : get the slides in the repository: ${data.length} items found.");

      print("mElkerm get the sliders in the repository");
      return data.map((item) => Slide.fromJSON(item)).toList();

    } else {
      print("mElkerm Error loading slides: in repo ${response.statusCode}");
      throw Exception('Failed to load slides');
    }
  }catch(err) {
    throw Exception('Error: $err');
  }

}
