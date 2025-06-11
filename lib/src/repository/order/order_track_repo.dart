import 'dart:convert';

import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;

import '../../models/order/tracking_order_model.dart';

Future<List<TrackingOrderModel>> getTrackingOrderModel({required String orderId}) async {
  print("mElkerm !!!!!!!!!! ##### Start to fetch the Tracking Order Data in the repository");
  try {
    final response = await http.get(
      Uri.parse('${GlobalConfiguration().getValue('api_base_url')}orders/${orderId}/status-history?api_token=IdIRGgs9SDwt6oL2duCJLauUsz9IRK8I4Nt9KJlw7mWNXcTGxoS9ssRDH13j'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      print("mElkerm !!!!!!!!!! ##### 00 : Tracking Order Data in the repository: ${response.body}");
      final Map<String, dynamic> data = json.decode(response.body);
      print("mElkerm !!!!!!!!!! ##### 11 : Tracking Order Data parsed successfully.");

      return [TrackingOrderModel.fromJson(data)];
    } else {
      print("mElkerm !!!!!!!!!! ##### Error loading Tracking Order Data : in repo ${response.statusCode}");
      throw Exception('Failed to load Tracking Order Data: ${response.statusCode}');
    }
  } catch(err) {
    print("mElkerm HELOLOLO ##### Error in Tracking Order Data: $err");
    throw Exception('Error: $err');
  }
}


