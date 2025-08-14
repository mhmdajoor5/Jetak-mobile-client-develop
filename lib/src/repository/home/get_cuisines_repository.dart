import 'dart:convert';

import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;

import '../../models/cuisine.dart';

Future<List<Cuisine>> getCuisines({String? type}) async {
  print("mElkerm Start to fetch the cuisines in the repository");
  try {
    String base = '${GlobalConfiguration().getValue('api_base_url')}cuisines';
    final uri = Uri.parse(base).replace(queryParameters: {
      if (type != null) 'type': type,
    });

    print("mElkerm Cuisines URL: $uri");

    final response = await http.get(
      uri,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      print("mElkerm 00 : get the Cuisines in the repository: ${response.body}");
      final decoded = json.decode(response.body);
      print("mElkerm Cuisines raw keys: ${decoded is Map ? (decoded as Map).keys : decoded.runtimeType}");

      // التحقق من وجود البيانات - لا نقوم بأي fallback عند عدم وجود بيانات
      if (decoded['data'] == null) {
        print("mElkerm Warning: data is null for type=$type – returning empty list");
        return [];
      }
      
      // دعم كلا الشكلين: data: [] أو data: { data: [] }
      List<dynamic> data;
      final dynamic inner = decoded['data'];
      if (inner is List) {
        data = inner;
      } else if (inner is Map && inner['data'] is List) {
        data = inner['data'] as List;
      } else {
        data = <dynamic>[];
      }

      print("mElkerm Cuisines parsed count: ${data.length} (type=$type)");
      if (data.isNotEmpty && data.first is Map) {
        print("mElkerm Cuisines first item keys: ${(data.first as Map).keys}");
      }

      print("mElkerm get the Cuisines in the repository");
      return data.map((item) => Cuisine.fromJSON(item)).toList();

    } else {
      print("mElkerm Error loading Cuisines: in repo ${response.statusCode}");
      throw Exception('Failed to load cuisines');
    }
  } catch (err) {
    print("mElkerm Exception in getCuisines: $err");

    throw Exception('Error: $err');
  }
} 