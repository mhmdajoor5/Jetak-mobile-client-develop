import 'dart:convert';
import 'dart:io';

import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;

import '../helpers/helper.dart';
import '../models/address.dart';
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
  print("=== getOrder Repository ===");
  print("Order ID: $orderId");
  
  User _user = userRepo.currentUser.value;
  if (_user == null || _user.apiToken == null) {
    print("❌ No user or API token available");
    throw Exception("User not authenticated");
  }
  
  final String _apiToken = 'api_token=${_user.apiToken}&';
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}orders/$orderId?${_apiToken}with=user;foodOrders;foodOrders.food;foodOrders.extras;orderStatus;deliveryAddress;payment;restaurant';
  
  print("🌐 Request URL: $url");
  
  try {
    final client = http.Client();
    final request = http.Request('get', Uri.parse(url));
    request.headers.addAll({
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    });
    
    final streamedRest = await client.send(request).timeout(Duration(seconds: 30));
    
    print("📊 Response status: ${streamedRest.statusCode}");
    
    if (streamedRest.statusCode != 200) {
      final errorBody = await streamedRest.stream
          .transform(utf8.decoder)
          .join();
      print("❌ Error response: $errorBody");
      throw Exception('HTTP ${streamedRest.statusCode}: $errorBody');
    }
    
    return streamedRest.stream
        .transform(utf8.decoder)
        .transform(json.decoder)
        .map((data) {
          print("🔍 Raw API Response: $data");
          final orderData = Helper.getData(data as Map<String, dynamic>?);
          print("🔍 Helper processed data: $orderData");
          final order = Order.fromJSON(orderData);
          print("✅ Order created: ID=${order.id}, Restaurant=${order.restaurant}");
          return order;
        });
        
  } catch (e) {
    print("❌ Error in getOrder: $e");
    rethrow;
  }
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
    
    // Build query parameters map with reduced data to avoid large responses
    final Map<String, String> queryParams = {
      'api_token': user.apiToken!,
      'with': 'user;orderStatus;payment', // Reduced includes to avoid large responses
      'search': 'user.id:${user.id}',
      'searchFields': 'user.id:=',
      'orderBy': 'updated_at',
      'sortedBy': 'desc',
      'limit': '10', // Reduced limit to avoid large responses
    };
    
    // Build URI with query parameters
    final Uri uri = Uri.parse(endpointUrl).replace(queryParameters: queryParams);
    final String url = uri.toString();
    
    print("🌐 Request URL: $url");
    print("📋 Query parameters: $queryParams");

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
          .timeout(Duration(seconds: 30)); // Reduced timeout

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

      // Transform stream with better error handling
      return streamedResponse.stream
          .transform(utf8.decoder)
          .handleError((error) {
            print("❌ UTF8 decode error: $error");
            // Return empty list instead of throwing
            return '';
          })
          .transform(json.decoder)
          .handleError((error) {
            print("❌ JSON decode error: $error");
            // Return empty map instead of throwing
            return <String, dynamic>{};
          })
          .map((data) {
            print("📦 Raw response data type: ${data.runtimeType}");
            
            try {
              if (data is Map<String, dynamic>) {
                return Helper.getData(data);
              } else {
                print("❌ Unexpected data type: ${data.runtimeType}");
                return <dynamic>[];
              }
            } catch (e) {
              print("❌ Helper.getData error: $e");
              return <dynamic>[];
            }
          })
          .expand((data) {
            print("📋 Expanded data type: ${data.runtimeType}");
            if (data is! List) {
              print("❌ Expected List but got: ${data.runtimeType}");
              return <dynamic>[]; // Return empty list instead of throwing
            }
            print("📋 Orders count: ${data.length}");
            return data;
          })
          .map((orderData) {
            try {
              print("🍽️ Processing order: ${orderData.toString().substring(0, 100)}...");
              
              final order = Order.fromJSON(orderData);
              print("✅ Order parsed successfully: ${order.id ?? 'unknown'}");
              return order;
            } catch (e) {
              print("❌ Order parsing error: $e");
              print("❌ Problematic data: $orderData");
              // Skip this order instead of throwing
              return null;
            }
          })
          .where((order) => order != null) // Filter out null orders
          .cast<Order>(); // Cast to Order type

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

// Simple fallback method for when the main method fails
Future<Stream<Order>> getRecentOrdersSimple() async {
  try {
    User? user = userRepo.currentUser.value;
    if (user == null || user.apiToken == null || user.apiToken!.isEmpty) {
      throw Exception('User not authenticated or missing API token');
    }

    final String? baseUrl = GlobalConfiguration().getValue('api_base_url');
    if (baseUrl == null || baseUrl.isEmpty) {
      throw Exception('API base URL not configured');
    }

    // Very simple request with minimal data
    final String url = '${baseUrl}orders?api_token=${user.apiToken}&with=orderStatus&search=user.id:${user.id}&searchFields=user.id:=&orderBy=updated_at&sortedBy=desc&limit=5';
    
    print("🌐 Simple Request URL: $url");

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ).timeout(Duration(seconds: 15));

    print("📊 Response status: ${response.statusCode}");

    if (response.statusCode != 200) {
      print("❌ Error response: ${response.body}");
      throw HttpException(
        'HTTP ${response.statusCode}: ${response.body}',
        uri: Uri.parse(url),
      );
    }

    // Parse response manually to handle errors gracefully
    try {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      final List<dynamic> ordersData = Helper.getData(jsonData) as List<dynamic>;
      
      return Stream.fromIterable(ordersData.map((orderData) {
        try {
          return Order.fromJSON(orderData);
        } catch (e) {
          print("❌ Failed to parse order: $e");
          return null;
        }
      }).where((order) => order != null).cast<Order>());
      
    } catch (e) {
      print("❌ JSON parsing error: $e");
      return Stream.empty();
    }

  } catch (e) {
    print("💥 Error in getRecentOrdersSimple: $e");
    return Stream.empty();
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
  
  // طباعة البيانات قبل الإرسال للتحقق
  print('📤 البيانات المرسلة للباك إند:');
  print('🔍 فحص حقل address:');
  if (params.containsKey('address')) {
    var addressValue = params['address'];
    print('   - نوع البيانات: ${addressValue.runtimeType}');
    print('   - القيمة: $addressValue');
    if (addressValue is String) {
      print('   - ✅ address هو String');
    } else {
      print('   - ❌ address ليس String! يجب أن يكون String');
    }
  } else {
    print('   - ⚠️ حقل address غير موجود في البيانات');
  }
  
  params.forEach((key, value) {
    if (key == 'address') {
      print('   - $key: "$value"'); // طباعة address كـ string
    } else {
      print('   - $key: $value');
    }
  });
  
  // طباعة البيانات النهائية قبل الإرسال
  print('📤 البيانات النهائية قبل الإرسال للباك إند:');
  print('   - JSON body: ${json.encode(params)}');
  
  final response = await client.post(
    Uri.parse(url),
    headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    body: json.encode(params),
  );
  
  // طباعة الاستجابة من الباك إند
  print('📥 الاستجابة من الباك إند:');
  print('   - Status Code: ${response.statusCode}');
  print('   - Response Body: ${response.body}');
  
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



// دالة منفصلة لإرسال بيانات العنوان فقط للباك إند
Future<Map<String, dynamic>> sendDeliveryAddress(Address address) async {
  User _user = userRepo.currentUser.value;
  if (_user.apiToken == null) {
    return {};
  }
  
  final String _apiToken = 'api_token=${_user.apiToken}';
  final String url = '${GlobalConfiguration().getValue('api_base_url')}delivery-address?$_apiToken';
  
      // تجميع المعلومات الإضافية في حقل instructions
    List<String> additionalInfo = [];
    if (address.description?.isNotEmpty == true) {
      additionalInfo.add("Building: ${address.description}");
    }
    if (address.type?.isNotEmpty == true) {
      additionalInfo.add("Entrance: ${address.type}");
    }
    if (address.entryMethod?.isNotEmpty == true) {
      additionalInfo.add("Floor: ${address.entryMethod}");
    }
    if (address.instructions?.isNotEmpty == true) {
      additionalInfo.add("Unit: ${address.instructions}");
    }
    if (address.label?.isNotEmpty == true) {
      additionalInfo.add("Label: ${address.label}");
    }
    
    Map<String, dynamic> addressData = {
      "delivery_address_id": address.id,
      "address": address.address ?? '',
      "latitude": address.latitude,
      "longitude": address.longitude,
    };
    
    // إضافة instructions إذا كانت هناك معلومات إضافية
    if (additionalInfo.isNotEmpty) {
      addressData["instructions"] = additionalInfo.join(", ");
    }
  
      print('📤 إرسال بيانات العنوان للباك إند:');
    print('   - address: ${address.address}');
    print('   - description (Building): ${address.description}');
    print('   - type (Entrance): ${address.type}');
    print('   - entryMethod (Floor): ${address.entryMethod}');
    print('   - instructions (Unit): ${address.instructions}');
    print('   - label: ${address.label}');
    if (additionalInfo.isNotEmpty) {
      print('   - instructions: ${additionalInfo.join(", ")}');
    }
    print('   - latitude: ${address.latitude}');
    print('   - longitude: ${address.longitude}');
  
  final client = new http.Client();
  final response = await client.post(
    Uri.parse(url),
    headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    body: json.encode(addressData),
  );
  
  print('📥 استجابة الباك إند: ${response.body}');
  
  return json.decode(response.body);
}

// احداثيات المستخدم الي في العنوان
// وفي احداثياتت المطعم
// الفرق بين المطعم والمستخدم
//
// بدك تقارنها ي ام اقل او تساوي الdelivery range

// وتاكد انو القيم المطعم بترجع صح


// lat - long المطعم
// lat - long المستخدم

// اذا كان الفرق بين المطعم والمستخدم اقل او يساوي الdelivery range

// يعني المستخدم في نطاق التوصيل