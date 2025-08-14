import 'dart:convert';

import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;

import '../../models/cuisine.dart';

Future<List<Cuisine>> getCuisines({String? type}) async {
  print("mElkerm Start to fetch the cuisines in the repository");
  try {
    String url = '${GlobalConfiguration().getValue('api_base_url')}cuisines';

    if (type != null) {
      url += '?type=$type';
    }

    final response = await http.get(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      print("mElkerm 00 : get the Cuisines in the repository: ${response.body}");
      final decoded = json.decode(response.body);
      
      // التحقق من وجود البيانات - إصلاح المنطق
      if (decoded['data'] == null) {
        print("mElkerm Warning: data is null for type=$type, trying without type parameter...");
        // إذا كانت البيانات null وكان هناك معامل type، جرب بدون معامل type
        if (type != null) {
          return await getCuisines(); // استدعاء بدون معامل type
        }
        return [];
      }
      
      final List<dynamic> data = decoded['data'];
      print("mElkerm 11 : get the Cuisines in the repository: ${data.length} items found.");
      print("mElkerm 22 : get the Cuisines in the repository: ${data.length} items found.");

      print("mElkerm get the Cuisines in the repository");
      return data.map((item) => Cuisine.fromJSON(item)).toList();

    } else {
      print("mElkerm Error loading Cuisines: in repo ${response.statusCode}");

      // إذا كان هناك خطأ مع type، جرب بدون type
      if (type != null) {
        print("mElkerm Trying without type parameter...");
        return await getCuisines(); // استدعاء بدون معامل type
      }

      throw Exception('Failed to load cuisines');
    }
  } catch (err) {
    print("mElkerm Exception in getCuisines: $err");

    // إذا كان هناك خطأ مع type، جرب بدون type
    if (type != null) {
      print("mElkerm Trying without type parameter due to exception...");
      return await getCuisines(); // استدعاء بدون معامل type
    }

    throw Exception('Error: $err');
  }
} 