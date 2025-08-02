import 'dart:convert';

import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;

import '../../models/order/tracking_order_model.dart';
import '../user_repository.dart' as userRepo;

Future<TrackingOrderModel> getTrackingOrderModel({required String orderId}) async {
  print("mElkerm !!!!!!!!!! ##### Start to fetch the Tracking Order Data in the repository");
  
  // الحصول على token المستخدم الحالي
  final user = userRepo.currentUser.value;
  if (user.apiToken == null || user.apiToken!.isEmpty) {
    print("❌ Error: User API token not available");
    throw Exception('User API token not available. Please login again.');
  }
  
  try {
    final url = '${GlobalConfiguration().getValue('api_base_url')}orders/${orderId}/status-history?api_token=${user.apiToken}';
    print("🌐 Requesting URL: $url");
    
    final response = await http.get(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
    );

    print("📊 Response status: ${response.statusCode}");
    print("📋 Response headers: ${response.headers}");
    
    if (response.statusCode == 200) {
      print("✅ Response received successfully");
      print("📦 Response body: ${response.body}");
      
      // التحقق من أن الاستجابة JSON وليس HTML
      if (response.body.trim().startsWith('<!DOCTYPE html>')) {
        print("❌ Error: Server returned HTML instead of JSON");
        throw Exception('Server returned HTML instead of JSON. Please check API endpoint.');
      }
      
      // التحقق من أن الاستجابة ليست فارغة
      if (response.body.trim().isEmpty) {
        print("❌ Error: Empty response from server");
        throw Exception('Empty response from server. Please try again.');
      }
      
      try {
        final Map<String, dynamic> data = json.decode(response.body);
        print("✅ JSON parsed successfully");
        
        // التحقق من أن البيانات تحتوي على المعلومات المطلوبة
        if (data['success'] == false) {
          print("❌ API returned success: false");
          throw Exception(data['message'] ?? 'Failed to load tracking data');
        }
        
        return TrackingOrderModel.fromJson(data);
      } catch (e) {
        print("❌ JSON parsing error: $e");
        throw Exception('Failed to parse JSON response: $e');
      }
    } else if (response.statusCode == 404) {
      print("❌ Error: Order not found (404)");
      throw Exception('Order not found. Please check the order ID.');
    } else if (response.statusCode == 401) {
      print("❌ Error: Unauthorized (401)");
      throw Exception('Unauthorized. Please login again.');
    } else {
      print("❌ Error response: ${response.statusCode}");
      print("❌ Error body: ${response.body}");
      throw Exception('Failed to load Tracking Order Data: ${response.statusCode}');
    }
  } catch(err) {
    print("mElkerm HELOLOLO ##### Error in Tracking Order Data: $err");
    throw Exception('Error: $err');
  }
}


