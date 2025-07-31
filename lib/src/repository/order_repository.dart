import 'dart:convert';
import 'dart:io';

import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;

import '../helpers/helper.dart';
import '../models/credit_card.dart';
import '../models/order.dart';
import '../models/order_status.dart';
import '../models/payment.dart';
import '../models/user.dart';
import '../repository/user_repository.dart' as userRepo;

Future<Stream<Order>> getOrders() async {
  User _user = userRepo.currentUser.value;
  final String _apiToken = 'api_token=${_user.apiToken}&';
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}orders?${_apiToken}with=user;foodOrders;foodOrders.food;foodOrders.extras;orderStatus;payment&search=user.id:${_user.id}&searchFields=user.id:=&orderBy=id&sortedBy=desc';

  final client = new http.Client();
  final streamedRest = await client.send(http.Request('get', Uri.parse(url)));

  return streamedRest.stream.transform(utf8.decoder).transform(json.decoder).map((data) => Helper.getData(data as Map<String, dynamic>?)).expand((data) => (data as List)).map((data) {
    return Order.fromJSON(data);
  });
}

Future<Stream<Order>> getOrder(orderId) async {
  User _user = userRepo.currentUser.value;
  final String _apiToken = 'api_token=${_user.apiToken}&';
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}orders/$orderId?${_apiToken}with=user;foodOrders;foodOrders.food;foodOrders.extras;orderStatus;deliveryAddress;payment';
  final client = new http.Client();
  final streamedRest = await client.send(http.Request('get', Uri.parse(url)));

  return streamedRest.stream.transform(utf8.decoder).transform(json.decoder).map((data) => Helper.getData(data as Map<String, dynamic>?)).map((data) {
    return Order.fromJSON(data);
  });
}
Future<Stream<Order>> getRecentOrders() async {
  try {
    // Validate user first
    User? user = userRepo.currentUser.value;
    if (user == null || user.apiToken == null || user.apiToken!.isEmpty) {
      throw Exception('User not authenticated or missing API token');
    }

    // Get base URL with validation
    final String? baseUrl = GlobalConfiguration().getValue('api_base_url');
    if (baseUrl == null || baseUrl.isEmpty) {
      throw Exception('API base URL not configured');
    }

    // Build base endpoint URL
    final String endpointUrl = '${baseUrl}orders';
    
    // Build query parameters map
    final Map<String, String> queryParams = {
      'api_token': user.apiToken!,
      // 'with': 'user;foodOrders;foodOrders.food;foodOrders.extras;orderStatus;payment',
      // 'search': 'user.id:${user.id}',
      // 'searchFields': 'user.id:=',
      'orderBy': 'updated_at',
      'sortedBy': 'desc',
      'limit': '2',
    };
    
    // Build URI with query parameters
    final Uri uri = Uri.parse(endpointUrl).replace(queryParameters: queryParams);
    final String url = uri.toString();
    
    print("🌐 Request URL: $url");

    // Create HTTP client with timeout
    final client = http.Client();
    
    try {
      // Create request with headers
      final request = http.Request('GET', Uri.parse(url));
      request.headers.addAll({
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'User-Agent': 'YourApp/1.0',
      });

      print("📤 Sending request...");
      
      // Send request with timeout
      final streamedResponse = await client.send(request)
          .timeout(Duration(seconds: 100));

      print("📊 Response status: ${streamedResponse.statusCode}");
      print("📋 Response headers: ${streamedResponse.headers}");

      // Check status code
      if (streamedResponse.statusCode != 200) {
        // Read error response
        final errorBody = await streamedResponse.stream
            .transform(utf8.decoder)
            .join();
        
        print("❌ Error response body: $errorBody");
        throw HttpException(
          'HTTP ${streamedResponse.statusCode}: $errorBody',
          uri: Uri.parse(url),
        );
      }

      print("✅ Response received successfully");

      // Transform stream with error handling
      return streamedResponse.stream
          .transform(utf8.decoder)
          .handleError((error) {
            print("❌ UTF8 decode error: $error");
            throw Exception('Failed to decode response: $error');
          })
          .transform(json.decoder)
          .handleError((error) {
            print("❌ JSON decode error: $error");
            throw Exception('Invalid JSON response: $error');
          })
          .map((data) {
            print("📦 Raw response data type: ${data.runtimeType}");
            print("📦 Raw response: $data");
            
            try {
              return Helper.getData(data as Map<String, dynamic>?);
            } catch (e) {
              print("❌ Helper.getData error: $e");
              throw Exception('Failed to process response data: $e');
            }
          })
          .expand((data) {
            print("📋 Expanded data type: ${data.runtimeType}");
            if (data is! List) {
              print("❌ Expected List but got: ${data.runtimeType}");
              throw Exception('Expected list of orders but got: ${data.runtimeType}');
            }
            print("📋 Orders count: ${data.length}");
            return data;
          })
          .map((orderData) {
            print("🍽️ Processing order: ${orderData.toString().substring(0, 100)}...");
            
            try {
              final order = Order.fromJSON(orderData);
              print("✅ Order parsed successfully: ${order.id ?? 'unknown'}");
              return order;
            } catch (e) {
              print("❌ Order parsing error: $e");
              print("❌ Problematic data: $orderData");
              throw Exception('Failed to parse order: $e');
            }
          });

    } finally {
      // Always close the client
      client.close();
    }

  } catch (e, stackTrace) {
    print("💥 Fatal error in getRecentOrders: $e");
    print("📍 Stack trace: $stackTrace");
    rethrow;
  }
}

// Alternative version with better error recovery
Future<Stream<Order>> getRecentOrdersWithRecovery() async {
  try {
    // Same validation and setup as above...
    User? user = userRepo.currentUser.value;
    if (user == null || user.apiToken == null || user.apiToken!.isEmpty) {
      throw Exception('User not authenticated or missing API token');
    }

    final String apiToken = 'api_token=${user.apiToken}&';
    final String? baseUrl = GlobalConfiguration().getValue('api_base_url');
    if (baseUrl == null || baseUrl.isEmpty) {
      throw Exception('API base URL not configured');
    }

    // Build base endpoint URL
    final String endpointUrl = '${baseUrl}orders';
    
    // Build query parameters map
    final Map<String, String> queryParams = {
      'api_token': user.apiToken!,
      'with': 'user;foodOrders;foodOrders.food;foodOrders.extras;orderStatus;payment',
      'search': 'user.id:${user.id}',
      'searchFields': 'user.id:=',
      'orderBy': 'updated_at',
      'sortedBy': 'desc',
      'limit': '20',
    };
    
    // Build URI with query parameters
    final Uri uri = Uri.parse(endpointUrl).replace(queryParameters: queryParams);
    final String url = uri.toString();

    final client = http.Client();
    
    try {
      final request = http.Request('GET', Uri.parse(url));
      request.headers.addAll({
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      });

      final streamedResponse = await client.send(request)
          .timeout(Duration(seconds: 30));

      if (streamedResponse.statusCode != 200) {
        final errorBody = await streamedResponse.stream
            .transform(utf8.decoder)
            .join();
        throw HttpException(
          'HTTP ${streamedResponse.statusCode}: $errorBody',
          uri: Uri.parse(url),
        );
      }

      // Enhanced stream processing with individual error handling
      return streamedResponse.stream
          .transform(utf8.decoder)
          .transform(json.decoder)
          .map((data) => Helper.getData(data as Map<String, dynamic>?))
          .expand((data) => (data as List))
          .map((orderData) {
            try {
              return Order.fromJSON(orderData);
            } catch (e) {
              // Log the error but don't stop the stream
              print("⚠️ Skipping invalid order: $e");
              return null;
            }
          })
          .where((order) => order != null) // Filter out null orders
          .cast<Order>(); // Cast to non-nullable Order

    } finally {
      client.close();
    }

  } catch (e, stackTrace) {
    print("💥 Error in getRecentOrdersWithRecovery: $e");
    print("📍 Stack trace: $stackTrace");
    rethrow;
  }
}



Future<Stream<OrderStatus>> getOrderStatus() async {
  User _user = userRepo.currentUser.value;
  final String _apiToken = 'api_token=${_user.apiToken}';
  final String url = '${GlobalConfiguration().getValue('api_base_url')}order_statuses?$_apiToken';

  final client = new http.Client();
  final streamedRest = await client.send(http.Request('get', Uri.parse(url)));

  return streamedRest.stream.transform(utf8.decoder).transform(json.decoder).map((data) => Helper.getData(data as Map<String, dynamic>?)).expand((data) => (data as List)).map((data) {
    return OrderStatus.fromJSON(data);
  });
}

Future<Order> addOrder(Order order, Payment payment) async {
  User _user = userRepo.currentUser.value;
  if (_user.apiToken == null) {
    return new Order();
  }
  CreditCard _creditCard = await userRepo.getCreditCard();
  order.user = _user;
  order.payment = payment;
  final String _apiToken = 'api_token=${_user.apiToken}';
  final String url = '${GlobalConfiguration().getValue('api_base_url')}orders?$_apiToken';
  final client = new http.Client();
  Map params = order.toMap();
  params.addAll(_creditCard.toMap());
  final response = await client.post(
    Uri.parse(url),
    headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    body: json.encode(params),
  );
  return Order.fromJSON(json.decode(response.body)['data']);
}

Future<Order> cancelOrder(Order order) async {
  print(order.toMap());
  User _user = userRepo.currentUser.value;
  final String _apiToken = 'api_token=${_user.apiToken}';
  final String url = '${GlobalConfiguration().getValue('api_base_url')}orders/${order.id}?$_apiToken';
  final client = new http.Client();
  final response = await client.put(
    Uri.parse(url),
    headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    body: json.encode(order.cancelMap()),
  );
  if (response.statusCode == 200) {
    return Order.fromJSON(json.decode(response.body)['data']);
  } else {
    throw new Exception(response.body);
  }
}
