import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:math' as math;
import 'package:http/http.dart' as http;

import '../../generated/l10n.dart';
import '../controllers/tracking_controller.dart';
import '../models/route_argument.dart';

class TrackingModernWidget extends StatefulWidget {
  final RouteArgument? routeArgument;

  const TrackingModernWidget({Key? key, this.routeArgument}) : super(key: key);

  @override
  _TrackingModernWidgetState createState() => _TrackingModernWidgetState();
}

class _TrackingModernWidgetState extends StateMVC<TrackingModernWidget> {
  late TrackingController _con;
  GoogleMapController? _mapController;
  VoidCallback? _driverLocationListener;
  Timer? _routeUpdateTimer;

  _TrackingModernWidgetState() : super(TrackingController()) {
    _con = controller as TrackingController;
  }

  bool _isLoadingRoute = true;
  String? _routeError;

  // Use your correct API key
  final String _apiKey = 'AIzaSyC6GK6c5IMopZIMo_F1btLZgYY4HTIuPLg';

  // Polyline
  PolylinePoints polylinePoints = PolylinePoints();
  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];
  
  // Current coordinates for fallback
  double? _currentRestaurantLat;
  double? _currentRestaurantLng;
  double? _currentClientLat;
  double? _currentClientLng;

  // Enhanced method to get the route polyline with better error handling
  _getPolyline() async {
    print("=== Starting Route Calculation ===");
    print("Order ID: ${_con.order.id}");
    print("Food Orders Count: ${_con.order.foodOrders.length}");
    print("Current polylines count: ${polylines.length}");
    print("Current polyline coordinates count: ${polylineCoordinates.length}");
    
    try {
      setState(() {
        _isLoadingRoute = true;
        _routeError = null;
      });
      
      // تحديث إحداثيات المطعم والمستخدم في الـ controller أولاً
      _updateControllerCoordinates();
      
      // استخراج الإحداثيات الفعلية من الطلب
      double? restaurantLat;
      double? restaurantLng;
      double? clientLat;
      double? clientLng;

      try {
        if (_con.order.foodOrders.isNotEmpty) {
          print("First food order restaurant data:");
          print("  - Restaurant name: ${_con.order.foodOrders[0].food?.restaurant.name}");
          print("  - Raw latitude: ${_con.order.foodOrders[0].food?.restaurant.latitude}");
          print("  - Raw longitude: ${_con.order.foodOrders[0].food?.restaurant.longitude}");
          
          restaurantLat = double.tryParse(
            _con.order.foodOrders[0].food?.restaurant.latitude ?? '',
          );
          restaurantLng = double.tryParse(
            _con.order.foodOrders[0].food?.restaurant.longitude ?? '',
          );
        } else {
          print("❌ No food orders available, checking controller coordinates");
          // استخدام إحداثيات المطعم من الـ controller
          if (_con.restaurantLocation != null) {
            restaurantLat = _con.restaurantLocation!.latitude;
            restaurantLng = _con.restaurantLocation!.longitude;
            print("✅ Using restaurant coordinates from controller: $restaurantLat, $restaurantLng");
          }
        }
        
        print("Delivery address data:");
        print("  - Address: ${_con.order.deliveryAddress.address}");
        print("  - Raw latitude: ${_con.order.deliveryAddress.latitude}");
        print("  - Raw longitude: ${_con.order.deliveryAddress.longitude}");
        
        clientLat = _con.order.deliveryAddress.latitude;
        clientLng = _con.order.deliveryAddress.longitude;
      } catch (e) {
        print("Error extracting coordinates: $e");
      }

      // حفظ الإحداثيات في متغيرات الكلاس للاستخدام لاحقاً
      _currentRestaurantLat = restaurantLat;
      _currentRestaurantLng = restaurantLng;
      _currentClientLat = clientLat;
      _currentClientLng = clientLng;

      // التحقق من صحة الإحداثيات
      bool hasRestaurantCoords = restaurantLat != null && restaurantLng != null && 
                                restaurantLat != 0.0 && restaurantLng != 0.0;
      bool hasClientCoords = clientLat != null && clientLng != null && 
                            clientLat != 0.0 && clientLng != 0.0;

      print("Restaurant: $restaurantLat, $restaurantLng (available: $hasRestaurantCoords)");
      print("Client: $clientLat, $clientLng (available: $hasClientCoords)");
      print("API Key: ${_apiKey.substring(0, 10)}...");

      // إذا لم تكن هناك إحداثيات متوفرة، تخطى حساب المسار
      if (!hasRestaurantCoords || !hasClientCoords) {
        print("⚠️ Skipping route calculation - missing coordinates:");
        print("   - Restaurant coordinates available: $hasRestaurantCoords");
        print("   - Client coordinates available: $hasClientCoords");
        
        setState(() {
          _isLoadingRoute = false;
          _routeError = null;
        });
        return;
      }

      // First, test the API key with a direct HTTP request
      await _testDirectionsAPI(restaurantLat!, restaurantLng!, clientLat!, clientLng!);

      // If test passes, proceed with polyline points
      print("Calling polylinePoints.getRouteBetweenCoordinates...");
      final result = await polylinePoints.getRouteBetweenCoordinates(
        googleApiKey: _apiKey,
        request: PolylineRequest(
          origin: PointLatLng(
            restaurantLat!,
            restaurantLng!,
          ),
          destination: PointLatLng(
            clientLat!,
            clientLng!,
          ),
          mode: TravelMode.driving,
        ),
      );

      print("Polyline API response received. Status: ${result.status}");
      print("Points count: ${result.points.length}");
      print("Error message: ${result.errorMessage}");
      print("Is successful: ${result.status == 'OK'}");

      if (result.status == null || result.status!.isEmpty) {
        throw Exception("Empty status from Directions API");
      }

      if (result.status != "OK") {
        String errorMsg = "API Error: ${result.status}";
        if (result.errorMessage != null && result.errorMessage!.isNotEmpty) {
          errorMsg += " - ${result.errorMessage}";
        }
        
        // Handle specific error types
        switch (result.status) {
          case "ZERO_RESULTS":
            errorMsg = "No route found between the selected points. Please check the locations.";
            break;
          case "REQUEST_DENIED":
            errorMsg = "API access denied. Please check your API key and restrictions.";
            break;
          case "INVALID_REQUEST":
            errorMsg = "Invalid request parameters.";
            break;
          case "OVER_QUERY_LIMIT":
            errorMsg = "API quota exceeded. Please try again later.";
            break;
        }
        
        throw Exception(errorMsg);
      }

      if (result.points.isEmpty) {
        throw Exception("No route points received despite OK status");
      }

      print("Converting ${result.points.length} points to LatLng...");
      polylineCoordinates = result.points
          .map((point) => LatLng(point.latitude, point.longitude))
          .toList();

      print("Successfully got ${polylineCoordinates.length} route points");
      print("First point: ${polylineCoordinates.isNotEmpty ? polylineCoordinates.first : 'N/A'}");
      print("Last point: ${polylineCoordinates.isNotEmpty ? polylineCoordinates.last : 'N/A'}");
      print("Calling _addPolyline()...");
      _addPolyline();

        } catch (e) {
      print("❌ Error in _getPolyline: $e");
      print("Error type: ${e.runtimeType}");
      print("Error details: ${e.toString()}");
      
      // إذا كان الخطأ ZERO_RESULTS، ارسم خط مستقيم
      if (e.toString().contains('ZERO_RESULTS') && 
          _currentRestaurantLat != null && _currentRestaurantLng != null &&
          _currentClientLat != null && _currentClientLng != null) {
        print("🔄 Drawing straight line as fallback for ZERO_RESULTS");
        _drawStraightLine(_currentRestaurantLat!, _currentRestaurantLng!, _currentClientLat!, _currentClientLng!);
        setState(() {
          _routeError = "No road route found. Showing straight line distance.";
        });
      } else {
        setState(() {
          _routeError = e.toString();
        });

        // Show error to user
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Route Error: ${e.toString()}"),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 5),
              action: SnackBarAction(
                label: "Retry",
                textColor: Colors.white,
                onPressed: _getPolyline,
              ),
            ),
          );
        }
      }
    } finally {
        if (mounted) {
          setState(() => _isLoadingRoute = false);
          print("Route calculation completed. Loading: false");
        }
      }
      
      print("=== Route Calculation Complete ===");
      print("=== Polyline Calculation Complete ===");
      print("=== Route Polyline Complete ===");
      print("=== Complete Route Polyline ===");
      print("=== Final Route Polyline ===");
      print("=== End Route Polyline ===");
    }

  // Test the Directions API directly to diagnose issues
  Future<void> _testDirectionsAPI(double restaurantLat, double restaurantLng, double clientLat, double clientLng) async {
    final url = "https://maps.googleapis.com/maps/api/directions/json?"
        "origin=$restaurantLat,$restaurantLng"
        "&destination=$clientLat,$clientLng"
        "&key=$_apiKey";

    print("=== Testing Directions API ===");
    print("URL: $url");
    print("Parameters:");
    print("  - Origin: $restaurantLat, $restaurantLng");
    print("  - Destination: $clientLat, $clientLng");
    print("  - API Key: ${_apiKey.substring(0, 10)}...");
    
    // حساب المسافة بين النقطتين
    double distance = _calculateDistance(restaurantLat, restaurantLng, clientLat, clientLng);
    print("  - Distance between points: ${distance.toStringAsFixed(2)} km");
    
    if (distance > 100) {
      print("⚠️ Warning: Distance is very large (${distance.toStringAsFixed(2)} km)");
    }

    try {
      final response = await http.get(Uri.parse(url)).timeout(
        Duration(seconds: 15),
        onTimeout: () => throw Exception("Request timeout"),
      );

      print("HTTP Response Status: ${response.statusCode}");
      print("Response Body Length: ${response.body.length}");
      
      if (response.statusCode != 200) {
        print("❌ HTTP Error: ${response.statusCode}");
        print("Response Body: ${response.body}");
        throw Exception("HTTP ${response.statusCode}: ${response.body}");
      }

      final data = jsonDecode(response.body);
      print("API Response Status: ${data['status']}");
      print("Full API Response: $data");
      
      if (data['status'] != 'OK') {
        String errorMsg = data['error_message'] ?? "Unknown API error";
        print("❌ API Error: ${data['status']} - $errorMsg");
        
        // معالجة خاصة لـ ZERO_RESULTS
        if (data['status'] == 'ZERO_RESULTS') {
          print("🔍 ZERO_RESULTS Analysis:");
          print("  - This usually means no route found between the points");
          print("  - Points might be in different countries/regions");
          print("  - Points might be in water or inaccessible areas");
          print("  - Try using 'mode=driving' explicitly");
          
          // محاولة بمعاملات مختلفة
          final fallbackUrl = "https://maps.googleapis.com/maps/api/directions/json?"
              "origin=$restaurantLat,$restaurantLng"
              "&destination=$clientLat,$clientLng"
              "&mode=driving"
              "&avoid=tolls"
              "&key=$_apiKey";
          
          print("🔄 Trying fallback request with different parameters...");
          print("Fallback URL: $fallbackUrl");
          
          try {
            final fallbackResponse = await http.get(Uri.parse(fallbackUrl)).timeout(Duration(seconds: 10));
            final fallbackData = jsonDecode(fallbackResponse.body);
            print("Fallback Response: ${fallbackData['status']}");
            
            if (fallbackData['status'] == 'OK') {
              print("✅ Fallback request succeeded!");
              // يمكن استخدام البيانات من fallbackData هنا
              return;
            }
          } catch (e) {
            print("❌ Fallback request also failed: $e");
          }
        }
        
        throw Exception("Directions API Error: ${data['status']} - $errorMsg");
      }

      print("✅ Direct API test successful");
      print("Routes count: ${data['routes']?.length ?? 0}");
      
      if (data['routes'] != null && data['routes'].isNotEmpty) {
        final route = data['routes'][0];
        print("First route overview_polyline: ${route['overview_polyline']?['points']?.substring(0, 50)}...");
      }
      
      print("=== Directions API Test Complete ===");
      
      print("=== API Test Complete ===");
      print("=== Directions Test Complete ===");
      print("=== Complete API Directions ===");
      print("=== Final API Directions ===");
      print("=== End API Directions ===");
      
    } catch (e) {
      print("❌ Direct API test failed: $e");
      throw e;
    }
  }

  // Method to add polyline to the map
  _addPolyline() {
    print("=== Adding Polyline to Map ===");
    print("Polyline coordinates count: ${polylineCoordinates.length}");
    print("Current polylines count: ${polylines.length}");
    
    try {
      
      if (polylineCoordinates.isEmpty) {
        throw Exception("No coordinates to draw polyline");
      }

      // طباعة أول وآخر نقطة في المسار
      if (polylineCoordinates.isNotEmpty) {
        print("First point: ${polylineCoordinates.first}");
        print("Last point: ${polylineCoordinates.last}");
      }

      final id = PolylineId("route_${DateTime.now().millisecondsSinceEpoch}");
      final polyline = Polyline(
        polylineId: id,
        color: _routeError != null && _routeError!.contains("straight line") 
            ? Colors.orange // لون مختلف للخط المستقيم
            : Color(0xFF26386A), // Match your app theme
        points: polylineCoordinates,
        width: 5,
        geodesic: true,
        patterns: _routeError != null && _routeError!.contains("straight line")
            ? [PatternItem.dash(20), PatternItem.gap(10)] // خط متقطع للخط المستقيم
            : [], // Solid line for normal route
      );

      print("Created polyline with ID: $id");
      print("Polyline points count: ${polyline.points.length}");

      setState(() {
        polylines = {id: polyline}; // Replace existing polylines
        print("Updated polylines set. Current count: ${polylines.length}");
        print("Polyline ID: $id");
        print("Polyline color: ${polyline.color}");
        print("Polyline width: ${polyline.width}");
        print("Polyline points count: ${polyline.points.length}");
      });

      // Zoom to fit the route with some delay to ensure map is ready
      Future.delayed(Duration(milliseconds: 500), () {
        if (_mapController != null && polylineCoordinates.isNotEmpty) {
          print("Zooming to fit polyline bounds");
          _mapController!.animateCamera(
            CameraUpdate.newLatLngBounds(
              _boundsFromLatLngList(polylineCoordinates),
              100.0, // increased padding
            ),
          );
        } else {
          print("⚠️ Cannot zoom: mapController=${_mapController != null}, coordinates=${polylineCoordinates.isNotEmpty}");
        }
      });

      print("✅ Polyline added successfully with ${polylineCoordinates.length} points");
      print("Final polylines count: ${polylines.length}");
      
      print("=== Polyline Addition Complete ===");
      print("=== Map Polyline Complete ===");
      print("=== Complete Polyline Map ===");
      print("=== Final Polyline Map ===");
      print("=== End Polyline Map ===");
    } catch (e) {
      print("❌ Error in _addPolyline: $e");
      print("Error details: ${e.toString()}");
    }
  }

  // Helper method to calculate bounds from a list of coordinates
  LatLngBounds _boundsFromLatLngList(List<LatLng> list) {
    double? x0, x1, y0, y1;
    for (LatLng latLng in list) {
      if (x0 == null) {
        x0 = x1 = latLng.latitude;
        y0 = y1 = latLng.longitude;
      } else {
        if (latLng.latitude > x1!) x1 = latLng.latitude;
        if (latLng.latitude < x0) x0 = latLng.latitude;
        if (latLng.longitude > y1!) y1 = latLng.longitude;
        if (latLng.longitude < y0!) y0 = latLng.longitude;
      }
    }
    return LatLngBounds(
      northeast: LatLng(x1!, y1!),
      southwest: LatLng(x0!, y0!),
    );
  }

  // دالة لحساب المسافة بين نقطتين جغرافيتين
  double _calculateDistance(double lat1, double lng1, double lat2, double lng2) {
    const double earthRadius = 6371; // نصف قطر الأرض بالكيلومتر
    double dLat = _degreesToRadians(lat2 - lat1);
    double dLng = _degreesToRadians(lng2 - lng1);
    
    double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(lat1)) * math.cos(_degreesToRadians(lat2)) *
        math.sin(dLng / 2) * math.sin(dLng / 2);
    
    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
  }
  
  double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180);
  }

  // دالة لرسم خط مستقيم بين المطعم والعميل
  void _drawStraightLine(double restaurantLat, double restaurantLng, double clientLat, double clientLng) {
    print("=== Drawing Straight Line ===");
    print("From: $restaurantLat, $restaurantLng");
    print("To: $clientLat, $clientLng");
    
    try {
      // إنشاء خط مستقيم بنقطتين فقط
      polylineCoordinates = [
        LatLng(restaurantLat, restaurantLng),
        LatLng(clientLat, clientLng),
      ];
      
      print("✅ Created straight line with ${polylineCoordinates.length} points");
      print("Distance: ${_calculateDistance(restaurantLat, restaurantLng, clientLat, clientLng).toStringAsFixed(2)} km");
      
      _addPolyline();
      
    } catch (e) {
      print("❌ Error drawing straight line: $e");
    }
  }

  // دالة جديدة لرسم خط بين السائق والعميل
  void _drawDriverToClientLine(double driverLat, double driverLng, double clientLat, double clientLng) {
    print("=== Drawing Driver to Client Line ===");
    print("From Driver: $driverLat, $driverLng");
    print("To Client: $clientLat, $clientLng");
    
    try {
      // إنشاء خط مباشر من السائق للعميل
      polylineCoordinates = [
        LatLng(driverLat, driverLng),
        LatLng(clientLat, clientLng),
      ];
      
      print("✅ Created driver-to-client line with ${polylineCoordinates.length} points");
      print("Distance: ${_calculateDistance(driverLat, driverLng, clientLat, clientLng).toStringAsFixed(2)} km");
      
      _addDriverClientPolyline();
      
    } catch (e) {
      print("❌ Error drawing driver-to-client line: $e");
    }
  }

  // دالة منفصلة لإضافة خط السائق-العميل مع لون مختلف
  _addDriverClientPolyline() {
    print("=== Adding Driver-Client Polyline to Map ===");
    print("Polyline coordinates count: ${polylineCoordinates.length}");
    
    try {
      if (polylineCoordinates.isEmpty) {
        throw Exception("No coordinates to draw driver-client polyline");
      }

      // طباعة أول وآخر نقطة في المسار
      if (polylineCoordinates.isNotEmpty) {
        print("Driver position: ${polylineCoordinates.first}");
        print("Client position: ${polylineCoordinates.last}");
      }

      final id = PolylineId("driver_to_client_${DateTime.now().millisecondsSinceEpoch}");
      final polyline = Polyline(
        polylineId: id,
        color: Color(0xFF00C853), // لون أخضر مشرق للخط من السائق للعميل
        points: polylineCoordinates,
        width: 5,
        geodesic: true,
        patterns: [PatternItem.dash(20), PatternItem.gap(10)], // خط متقطع مميز
      );

      print("Created driver-client polyline with ID: $id");
      print("Polyline points count: ${polyline.points.length}");

      setState(() {
        polylines = {id: polyline}; // استبدال الخط القديم بالخط الجديد
        _isLoadingRoute = false;
        _routeError = null;
      });

      print("✅ Driver-client polyline added successfully");
      
    } catch (e) {
      print("❌ Error adding driver-client polyline: $e");
      setState(() {
        _routeError = "Failed to draw driver route: $e";
        _isLoadingRoute = false;
      });
    }
  }

  // دالة لتحديد نوع الخط المطلوب رسمه
  void _updateRouteBasedOnDriverLocation() {
    print("=== Updating Route Based on Driver Location ===");
    
    // التحقق من وجود إحداثيات العميل
    double? clientLat = _con.order.deliveryAddress.latitude;
    double? clientLng = _con.order.deliveryAddress.longitude;
    
    if (clientLat == null || clientLng == null || clientLat == 0.0 || clientLng == 0.0) {
      print("❌ Client coordinates not available");
      return;
    }

    // التحقق من وجود موقع السائق
    bool hasDriverLocation = _con.driverLocation.latitude != 0.0 && _con.driverLocation.longitude != 0.0;
    
    if (hasDriverLocation) {
      // رسم خط من السائق للعميل
      print("✅ Driver location available, drawing driver-to-client route");
      print("🚗 Driver at: ${_con.driverLocation.latitude}, ${_con.driverLocation.longitude}");
      print("🏠 Client at: $clientLat, $clientLng");
      _drawDriverToClientLine(
        _con.driverLocation.latitude, 
        _con.driverLocation.longitude, 
        clientLat, 
        clientLng
      );
    } else {
      // رسم خط من المطعم للعميل (الطريقة القديمة)
      print("⚠️ Driver location not available, falling back to restaurant-to-client route");
      _getPolyline(); // استخدام الطريقة الأصلية
    }
  }

  @override
  void initState() {
    super.initState();
    print("=== TrackingModernWidget initState ===");
    print("Route Argument ID: ${widget.routeArgument?.id}");
    
    if (widget.routeArgument != null && widget.routeArgument!.id != null) {
      print("Starting order tracking for ID: ${widget.routeArgument!.id}");
      _con.listenForOrder(orderId: widget.routeArgument!.id!);
      _con.getOrderDetailsTracking(orderId: widget.routeArgument!.id!);
      
      // إضافة listener لتحديث الخريطة عندما يتغير موقع السائق
      _driverLocationListener = () {
        if (mounted) {
          print("🔄 Driver location updated, rebuilding map...");
          print("🚗 New driver position: ${_con.driverLocation}");
          
          // إعادة رسم الخط بناءً على موقع السائق الجديد
          print("🔄 Updating route line due to driver location change");
          _updateRouteBasedOnDriverLocation();
          
          // تحديث موضع الكاميرا للتركيز على السائق إذا كان موجود
          if (_mapController != null && _con.driverLocation.latitude != 0.0 && _con.driverLocation.longitude != 0.0) {
            _mapController!.animateCamera(
              CameraUpdate.newLatLng(_con.driverLocation),
            );
            print("📍 Camera animated to driver location");
          }
          
          setState(() {});
        }
      };
      _con.addListener(_driverLocationListener!);
      
      // إضافة retry mechanism لتحميل Order إذا فشل
      Timer.periodic(Duration(seconds: 3), (timer) {
        if (_con.order.id.isEmpty && timer.tick < 5) {
          print("🔄 Retrying order loading... attempt ${timer.tick}");
          _con.listenForOrder(orderId: widget.routeArgument!.id!);
        } else {
          timer.cancel();
          if (_con.order.id.isNotEmpty) {
            print("✅ Order loaded successfully on retry");
          }
        }
      });
    } else {
      print("❌ No route argument or ID provided");
    }
    
    loadMotorcycleIcon();
    
    // Delay route calculation to ensure order data is loaded
    print("Scheduling route calculation in 2 seconds...");
    Future.delayed(Duration(milliseconds: 2000), () {
      if (mounted) {
        print("Executing delayed route calculation...");
        print("Order ID: ${_con.order.id}");
        print("Food Orders Count: ${_con.order.foodOrders.length}");
        _updateControllerCoordinates();
        
        // استخدام الدالة الجديدة التي تحدد نوع الخط بناءً على موقع السائق
        _updateRouteBasedOnDriverLocation();
        
        // تحديث دوري للخط في حالة وصول موقع السائق متأخراً
        _routeUpdateTimer = Timer.periodic(Duration(seconds: 5), (timer) {
          if (mounted && timer.tick < 12) { // التحقق لمدة دقيقة واحدة كحد أقصى
            bool hasDriverLocation = _con.driverLocation.latitude != 0.0 && _con.driverLocation.longitude != 0.0;
            if (hasDriverLocation) {
              print("🔄 Periodic check: Driver location found, updating route");
              _updateRouteBasedOnDriverLocation();
              timer.cancel(); // إيقاف التحقق الدوري بعد وجود السائق
              _routeUpdateTimer = null;
            } else {
              print("⏰ Periodic check ${timer.tick}: Still waiting for driver location...");
            }
          } else {
            timer.cancel();
            _routeUpdateTimer = null;
          }
        });
      } else {
        print("Widget not mounted, skipping route calculation");
              }
      });
      
      print("=== initState Complete ===");
      print("=== Widget Init Complete ===");
      print("=== Tracking Init Complete ===");
      print("=== Complete Init State ===");
      print("=== Final Init State ===");
      print("=== End Init State ===");
    }
    
    @override
    void dispose() {
      // إزالة listener عند إزالة الـ widget
      if (_driverLocationListener != null) {
        _con.removeListener(_driverLocationListener!);
      }
      
      // إيقاف timer التحديث الدوري للخط
      _routeUpdateTimer?.cancel();
      
      _con.dispose(); // تنظيف موارد الكنترولر
      super.dispose();
    }
    


  // دالة لتحديث إحداثيات المطعم والمستخدم في الـ controller
  void _updateControllerCoordinates() {
    try {
      print("=== Updating Controller Coordinates ===");
      
      // استخراج إحداثيات المطعم من الطلب
      if (_con.order.foodOrders.isNotEmpty) {
        print("Processing restaurant coordinates...");
        print("  - Raw latitude: ${_con.order.foodOrders[0].food?.restaurant.latitude}");
        print("  - Raw longitude: ${_con.order.foodOrders[0].food?.restaurant.longitude}");
        
        double? restaurantLat = double.tryParse(
          _con.order.foodOrders[0].food?.restaurant.latitude ?? '',
        );
        double? restaurantLng = double.tryParse(
          _con.order.foodOrders[0].food?.restaurant.longitude ?? '',
        );
        
        print("  - Parsed latitude: $restaurantLat");
        print("  - Parsed longitude: $restaurantLng");
        
        if (restaurantLat != null && restaurantLng != null && 
            restaurantLat != 0.0 && restaurantLng != 0.0) {
          _con.restaurantLocation = LatLng(restaurantLat, restaurantLng);
          print("✅ Updated restaurant location: $_con.restaurantLocation");
        } else {
          print("⚠️ Restaurant coordinates invalid or zero");
        }
      } else {
        print("❌ No food orders available for restaurant coordinates");
        // التحقق من وجود إحداثيات المطعم في الـ controller
        if (_con.restaurantLocation != null) {
          print("✅ Restaurant location already available in controller: $_con.restaurantLocation");
        } else {
          print("⚠️ No restaurant location in controller either");
        }
      }
      
      // استخراج إحداثيات العميل من العنوان
      print("Processing client coordinates...");
      print("  - Raw latitude: ${_con.order.deliveryAddress.latitude}");
      print("  - Raw longitude: ${_con.order.deliveryAddress.longitude}");
      
      double? clientLat = _con.order.deliveryAddress.latitude;
      double? clientLng = _con.order.deliveryAddress.longitude;
      
      print("  - Parsed latitude: $clientLat");
      print("  - Parsed longitude: $clientLng");
      
      if (clientLat != null && clientLng != null && 
          clientLat != 0.0 && clientLng != 0.0) {
        _con.clientLocation = LatLng(clientLat, clientLng);
        print("✅ Updated client location: $_con.clientLocation");
      } else {
        print("⚠️ Client coordinates invalid or zero");
      }
      
      print("=== Controller Coordinates Update Complete ===");
      print("Final restaurant location: $_con.restaurantLocation");
      print("Final client location: $_con.clientLocation");
      
      print("=== Coordinates Update Complete ===");
      print("=== Controller Update Complete ===");
      print("=== Complete Coordinates Controller ===");
      print("=== Final Coordinates Controller ===");
      print("=== End Coordinates Controller ===");
      
    } catch (e) {
      print("❌ Error updating coordinates: $e");
      print("Error details: ${e.toString()}");
    }
  }

  BitmapDescriptor? motorcycleIcon;

  Future<void> loadMotorcycleIcon() async {
    try {
      print("🔄 Loading motorcycle icon for driver...");
      motorcycleIcon = await BitmapDescriptor.asset(
        ImageConfiguration(size: Size(48, 48)),
        'assets/img/pointer.png',
      );
      print("✅ Motorcycle icon loaded successfully for driver");
      if (mounted) {
        setState(() {});
        print("🔄 Map rebuilt with motorcycle icon for driver");
      }
    } catch (e) {
      print("❌ Error loading motorcycle icon: $e");
      // Use default red marker as fallback for driver
    }
  }

  @override
  Widget build(BuildContext context) {
    print('Order ID: ${widget.routeArgument?.id}');
    print('Food Orders Length: ${_con.order.foodOrders.length}');
    print('Address: ${_con.order.deliveryAddress.address}');

    // Show loading screen if order data is not ready
    print("=== Building Tracking Widget ===");
    print("Order ID: ${_con.order.id}");
    print("Food Orders Count: ${_con.order.foodOrders.length}");
    print("Order Status: ${_con.order.orderStatus.status}");
    
    // تعديل الشرط ليسمح بعرض الخريطة حتى لو لم تكن هناك foodOrders
    if (_con.order.id == null || _con.order.id.isEmpty) {
      print("❌ Order data not ready, showing loading screen");
      return Scaffold(
        // appBar: _buildAppBar(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: Color(0xFF26386A),
              ),
              SizedBox(height: 16),
              Text(
                "Loading order details...",
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF272727),
                ),
              ),
              SizedBox(height: 8),
              Text(
                "Please wait while we fetch your order information",
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF9D9FA4),
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    print("✅ Order data ready, building map");

    // Extract coordinates with better error handling
    double? restaurantLat;
    double? restaurantLng;
    double? clientLat;
    double? clientLng;

    try {
      if (_con.order.foodOrders.isNotEmpty) {
        restaurantLat = double.tryParse(
          _con.order.foodOrders[0].food?.restaurant.latitude ?? '',
        );
        restaurantLng = double.tryParse(
          _con.order.foodOrders[0].food?.restaurant.longitude ?? '',
        );
      } else if (_con.restaurantLocation != null) {
        // استخدام إحداثيات المطعم من الـ controller
        restaurantLat = _con.restaurantLocation!.latitude;
        restaurantLng = _con.restaurantLocation!.longitude;
        print("Using restaurant coordinates from controller: $restaurantLat, $restaurantLng");
      }
      
      clientLat = _con.order.deliveryAddress.latitude;
      clientLng = _con.order.deliveryAddress.longitude;
    } catch (e) {
      print("Error extracting coordinates: $e");
    }

    // Validate coordinates - تعديل للسماح بعرض الخريطة حتى لو كانت إحداثيات واحدة فقط متوفرة
    bool hasRestaurantCoords = restaurantLat != null && restaurantLng != null && 
                              restaurantLat != 0.0 && restaurantLng != 0.0;
    bool hasClientCoords = clientLat != null && clientLng != null && 
                          clientLat != 0.0 && clientLng != 0.0;
    
    // إذا لم تكن هناك أي إحداثيات متوفرة، اعرض رسالة خطأ
    if (!hasRestaurantCoords && !hasClientCoords) {
      print("❌ Tracking Error: No coordinates available");
      print("   - Restaurant coordinates: lat=$restaurantLat, lng=$restaurantLng");
      print("   - Client coordinates: lat=$clientLat, lng=$clientLng");
      
      return Scaffold(
        body: _buildErrorView("No location data available for this order."),
      );
    }
    
    // إذا كانت هناك إحداثيات متوفرة، اعرض الخريطة بدون مسار
    print("✅ Showing map with available coordinates:");
    print("   - Restaurant coordinates: lat=$restaurantLat, lng=$restaurantLng (available: $hasRestaurantCoords)");
    print("   - Client coordinates: lat=$clientLat, lng=$clientLng (available: $hasClientCoords)");
    print("   - Polylines count: ${polylines.length}");
    print("   - Polyline coordinates count: ${polylineCoordinates.length}");

    // Build markers - بناء العلامات المتوفرة فقط
    Set<Marker> markers = {};
    
    print("Building markers...");
    
    // Add restaurant marker if coordinates are available
    if (hasRestaurantCoords) {
      print("Adding restaurant marker at: $restaurantLat, $restaurantLng");
      markers.add(
        Marker(
          markerId: MarkerId('restaurant'),
          position: LatLng(restaurantLat!, restaurantLng!),
          infoWindow: InfoWindow(
            title: '🏪 Restaurant (Red Marker)',
            snippet: _con.order.foodOrders.isNotEmpty 
              ? _con.order.foodOrders[0].food?.restaurant.name ?? 'Restaurant'
              : 'Restaurant',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed), // marker أحمر للمطعم
        ),
      );
    } else {
      print("❌ Restaurant coordinates not available for marker");
    }

    // Add client marker if coordinates are available

    
    // Add client marker if coordinates are available
    if (hasClientCoords) {
      print("Adding client marker at: $clientLat, $clientLng");
      markers.add(
        Marker(
          markerId: MarkerId('client'),
          position: LatLng(clientLat!, clientLng!),
          infoWindow: InfoWindow(
            title: '🏠 Delivery Address (Blue Marker)',
            snippet: _con.order.deliveryAddress.address,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue), // marker أزرق للعميل
        ),
      );
    } else {
      print("❌ Client coordinates not available for marker");
    }
    
    // Add driver marker if coordinates are available (only once)
    if (_con.driverLocation.latitude != 0.0 && _con.driverLocation.longitude != 0.0) {
      print("✅ Adding driver marker at: ${_con.driverLocation.latitude}, ${_con.driverLocation.longitude}");
      print("🚗 Driver marker details:");
      print("   - Position: ${_con.driverLocation}");
      print("   - Motorcycle icon loaded: ${motorcycleIcon != null}");
      print("   - Order ID: ${_con.order.id}");
      
      // استخدام marker ID ثابت للسائق لضمان عدم التكرار
      markers.add(
        Marker(
          markerId: MarkerId('driver_location'), // ID ثابت للسائق
          position: _con.driverLocation,
          infoWindow: InfoWindow(
            title: '🛵 Driver Location (Live)',
            snippet: 'Order ID: ${_con.order.id}\nLat: ${_con.driverLocation.latitude.toStringAsFixed(6)}\nLng: ${_con.driverLocation.longitude.toStringAsFixed(6)}\n🔄 Live tracking active',
          ),
          icon: motorcycleIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen), // أخضر للسائق
        ),
      );
      print("✅ Driver marker added successfully to markers set");
    } else {
      print("❌ Driver coordinates not available for marker: lat=${_con.driverLocation.latitude}, lng=${_con.driverLocation.longitude}");
    }
    
    print("Total markers created: ${markers.length}");

    // Calculate camera position based on available coordinates
    LatLng cameraTarget;
    double zoom = 12;
    
    print("Calculating camera position...");
    
    // التحقق من وجود موقع السائق
    bool hasDriverCoords = _con.driverLocation.latitude != 0.0 && _con.driverLocation.longitude != 0.0;
    
    if (hasRestaurantCoords && hasClientCoords && hasDriverCoords) {
      // All three coordinates available - center between all points
      double avgLat = (restaurantLat! + clientLat! + _con.driverLocation.latitude) / 3;
      double avgLng = (restaurantLng! + clientLng! + _con.driverLocation.longitude) / 3;
      cameraTarget = LatLng(avgLat, avgLng);
      zoom = 12; // zoom in a bit more to show all points clearly
      print("✅ Camera centered between restaurant, client, and driver");
      print("📍 Camera target: $cameraTarget, zoom: $zoom");
    } else if (hasDriverCoords && hasClientCoords) {
      // Driver and client available - center between them
      double avgLat = (clientLat! + _con.driverLocation.latitude) / 2;
      double avgLng = (clientLng! + _con.driverLocation.longitude) / 2;
      cameraTarget = LatLng(avgLat, avgLng);
      zoom = 13;
      print("✅ Camera centered between driver and client");
      print("📍 Camera target: $cameraTarget, zoom: $zoom");
    } else if (hasDriverCoords && hasRestaurantCoords) {
      // Driver and restaurant available - center between them
      double avgLat = (restaurantLat! + _con.driverLocation.latitude) / 2;
      double avgLng = (restaurantLng! + _con.driverLocation.longitude) / 2;
      cameraTarget = LatLng(avgLat, avgLng);
      zoom = 13;
      print("✅ Camera centered between driver and restaurant");
      print("📍 Camera target: $cameraTarget, zoom: $zoom");
    } else if (hasDriverCoords) {
      // Only driver available - center on driver
      cameraTarget = _con.driverLocation;
      zoom = 15;
      print("✅ Camera centered on driver location");
      print("📍 Camera target: $cameraTarget, zoom: $zoom");
    } else if (hasRestaurantCoords && hasClientCoords) {
      // Both coordinates available - center between them
      cameraTarget = LatLng(
        (restaurantLat! + clientLat!) / 2,
        (restaurantLng! + clientLng!) / 2,
      );
      zoom = 12;
      print("✅ Camera centered between restaurant and client");
    } else if (hasRestaurantCoords && hasDriverCoords) {
      // Restaurant and driver coordinates available
      cameraTarget = LatLng(
        (restaurantLat! + _con.driverLocation.latitude) / 2,
        (restaurantLng! + _con.driverLocation.longitude) / 2,
      );
      zoom = 12;
      print("✅ Camera centered between restaurant and driver");
    } else if (hasClientCoords && hasDriverCoords) {
      // Client and driver coordinates available
      cameraTarget = LatLng(
        (clientLat! + _con.driverLocation.latitude) / 2,
        (clientLng! + _con.driverLocation.longitude) / 2,
      );
      zoom = 12;
      print("✅ Camera centered between client and driver");
    } else if (hasRestaurantCoords) {
      // Only restaurant coordinates available
      cameraTarget = LatLng(restaurantLat!, restaurantLng!);
      zoom = 14;
      print("⚠️ Camera centered on restaurant only");
    } else if (hasClientCoords) {
      // Only client coordinates available
      cameraTarget = LatLng(clientLat!, clientLng!);
      zoom = 14;
      print("⚠️ Camera centered on client only");
    } else if (hasDriverCoords) {
      // Only driver coordinates available
      cameraTarget = _con.driverLocation;
      zoom = 14;
      print("⚠️ Camera centered on driver only");
    } else {
      // No coordinates available - use default
      cameraTarget = LatLng(37.785834, -122.406417); // San Francisco default
      zoom = 10;
      print("❌ No coordinates available, using default location");
    }
    
    print("Camera target: $cameraTarget, zoom: $zoom");
    print("Final polylines count: ${polylines.length}");
    print("Final markers count: ${markers.length}");
    print("=== Building Complete ===");
    print("=== Widget Build Complete ===");
    print("=== Tracking Widget Complete ===");
    print("=== Complete Widget Build ===");
    print("=== Final Widget Build ===");
    print("=== End Widget Build ===");
    print("=== Final End Widget Build ===");

    return Scaffold(
      // appBar: _buildAppBar(),
      body: Stack(
        children: [
          // Map
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: cameraTarget,
              zoom: zoom,
            ),
            markers: markers,
            polylines: polylines.values.toSet(),
            onMapCreated: (controller) async {
              _mapController = controller;
              print("Map created successfully");
              print("Markers count: ${markers.length}");
              print("Polylines count: ${polylines.length}");
              
              // Apply custom map style
              try {
                final mapStyle = await DefaultAssetBundle.of(context).loadString('assets/cfg/map_style.json');
                controller.setMapStyle(mapStyle);
              } catch (e) {
                print("Error loading map style: $e");
              }
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
          ),
          
          // Loading overlay
          if (_isLoadingRoute && _routeError == null)
            Center(
              child: Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      color: Color(0xFF26386A),
                    ),
                    SizedBox(height: 12),
                    Text(
                      "Loading route...",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF272727),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          
          // Error/Info overlay
          if (_routeError != null)
            Positioned(
              top: 20,
              left: 20,
              right: 20,
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _routeError!.contains("straight line") 
                      ? Colors.orange.shade50 
                      : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _routeError!.contains("straight line") 
                        ? Colors.orange.shade200 
                        : Colors.red.shade200
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _routeError!.contains("straight line") 
                          ? Icons.info_outline 
                          : Icons.error_outline, 
                      color: _routeError!.contains("straight line") 
                          ? Colors.orange 
                          : Colors.red
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _routeError!.contains("straight line") 
                                ? "Showing Straight Line Distance" 
                                : "Route Loading Failed",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _routeError!.contains("straight line") 
                                  ? Colors.orange.shade800 
                                  : Colors.red.shade800,
                            ),
                          ),
                          Text(
                            _routeError!,
                            style: TextStyle(
                              fontSize: 12,
                              color: _routeError!.contains("straight line") 
                                  ? Colors.orange.shade700 
                                  : Colors.red.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!_routeError!.contains("straight line"))
                      TextButton(
                        onPressed: _getPolyline,
                        child: Text("Retry"),
                      ),
                  ],
                ),
              ),
            ),
          
          // Draggable Bottom sheet
          _buildDraggableBottomSheet(),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      title: Text(
        S.of(context).tracking,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          color: Color(0xFF272727),
        ),
      ),
      leading: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Container(
          margin: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: Color(0xFFE7E7E9)),
          ),
          child: Icon(Icons.arrow_back, color: Colors.black),
        ),
      ),
    );
  }

  Widget _buildErrorView(String message) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_off,
              size: 64,
              color: Colors.orange,
            ),
            SizedBox(height: 20),
            Text(
              "Tracking Unavailable",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF272727),
              ),
            ),
            SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF9D9FA4),
              ),
            ),
            SizedBox(height: 20),
            Text(
              "This might be due to:",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF272727),
              ),
            ),
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "• Missing location data from the order",
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF666666),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "• Invalid coordinates in the delivery address",
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF666666),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "• Restaurant location not properly set",
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF666666),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF26386A),
                    foregroundColor: Colors.white,
                  ),
                  child: Text("Go Back"),
                ),
                ElevatedButton(
                  onPressed: () {
                    // يمكن إضافة إعادة تحميل الصفحة هنا
                    setState(() {});
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                  child: Text("Retry"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDraggableBottomSheet() {
    return DraggableScrollableSheet(
      initialChildSize: 0.35, // البداية عند 35% من الشاشة
      minChildSize: 0.12, // أقل حجم 12% من الشاشة (عرض معلومات السائق الأساسية فقط)
      maxChildSize: 0.85, // أكبر حجم 85% من الشاشة (عرض كامل المعلومات)
      snap: true, // التقاط لمواضع محددة
      snapSizes: [0.15, 0.35, 0.85], // مواضع التقاط: مطوي، متوسط، مفتوح كاملاً
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 15,
                spreadRadius: 3,
                offset: Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            children: [
              // Handle للسحب - أكثر وضوحاً وسهولة في الاستخدام
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Center(
                  child: Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Color(0xFFBBBBBB),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
              ),
              // المحتوى القابل للتمرير
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 10),
                      _buildBottomSheetContent(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomSheetContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // معلومات السائق
        Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundImage: AssetImage(
                "assets/images/image-removebg-preview.png",
              ),
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _con.trackingOrderDetails?.data.driver?.name ?? "Driver",
                  style: TextStyle(
                    fontFamily: "Nunito",
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    height: 1.0,
                    letterSpacing: -0.02,
                    color: Color(0xFF272727),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Courier",
                  style: TextStyle(
                    fontFamily: "Nunito",
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                    height: 1.4,
                    letterSpacing: -0.02,
                    color: Color(0xFF9D9FA4),
                  ),
                ),
              ],
            ),
            Spacer(),
            // يمكن إضافة أزرار الاتصال والرسائل هنا
          ],
        ),
        
        SizedBox(height: 20),
        
        // خط فاصل
        LayoutBuilder(
          builder: (context, constraints) => Row(
            children: List.generate(
              (constraints.maxWidth / 10).floor(),
              (index) {
                return Container(
                  width: 6,
                  height: 1,
                  margin: EdgeInsets.symmetric(horizontal: 2),
                  color: Color(0xFFE7E7E9),
                );
              },
            ),
          ),
        ),
        
        SizedBox(height: 20),
        
        // خطوات الطلب
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: _buildStepProgress(_con.order.orderStatus.id),
        ),
        
        SizedBox(height: 20),
        
        // معلومات التوصيل
        _buildInfoTile(
          "Delivery time",
          "assets/img/clock.svg",
          _con.trackingOrderDetails?.data.estimatedTime ?? "Calculating...",
        ),
        _buildInfoTile(
          "Delivery address",
          "assets/img/locationorder.svg",
          _con.order.deliveryAddress.address ?? "Address not available",
        ),
        _buildInfoTile(
          "Order ID",
          "assets/img/bag.svg",
          "#${_con.order.id}",
        ),
        
        // معلومات موقع السائق إذا كان متوفر
        if (_con.driverLocation.latitude != 0.0 && _con.driverLocation.longitude != 0.0)
          _buildInfoTile(
            "Driver Location",
            "assets/img/location.svg",
            "Lat: ${_con.driverLocation.latitude.toStringAsFixed(6)}\nLng: ${_con.driverLocation.longitude.toStringAsFixed(6)}\n🔄 Live updates active",
          ),
        
        // حالة التتبع المباشر
        _buildInfoTile(
          "Live Tracking",
          "assets/img/notification-bing.svg",
          _con.driverLocation.latitude != 0.0 && _con.driverLocation.longitude != 0.0 
            ? "✅ Connected - Driver location updated"
            : "🔄 Connecting to driver...",
        ),
        
        SizedBox(height: 100), // مساحة إضافية في الأسفل
      ],
    );
  }

  // Keep all your existing _buildStepProgress methods and other UI methods...
  Widget _buildStepProgress(String? statusId) {
    switch (statusId) {
      case '1':
      case '2':
        return _buildStepProgress1();
      case '3':
        return _buildStepProgress2();
      case '4':
        return _buildStepProgress3();
      case '5':
        return _buildStepProgress4();
      default:
        return _buildStepProgress1();
    }
  }

  Widget _buildStepProgress1() {
    return Row(
      children: [
        _buildStepIcon('assets/img/receipt-item.svg', true),
        _buildDashedLine(false),
        _buildStepIcon('assets/img/reserve.svg', false),
        _buildDashedLine(false),
        _buildStepIcon('assets/img/truck-fast.svg', false),
        _buildDashedLine(false),
        _buildStepIcon('assets/img/tick-circle.svg', false),
      ],
    );
  }

  Widget _buildStepProgress2() {
    return Row(
      children: [
        _buildStepIcon('assets/img/receipt-item.svg', true),
        _buildDashedLine(true),
        _buildStepIcon('assets/img/reserve.svg', true),
        _buildDashedLine(false),
        _buildStepIcon('assets/img/truck-fast.svg', false),
        _buildDashedLine(false),
        _buildStepIcon('assets/img/tick-circle.svg', false),
      ],
    );
  }

  Widget _buildStepProgress3() {
    return Row(
      children: [
        _buildStepIcon('assets/img/receipt-item.svg', true),
        _buildDashedLine(true),
        _buildStepIcon('assets/img/reserve.svg', true),
        _buildDashedLine(true),
        _buildStepIcon('assets/img/truck-fast.svg', true),
        _buildDashedLine(false),
        _buildStepIcon('assets/img/tick-circle.svg', false),
      ],
    );
  }

  Widget _buildStepProgress4() {
    return Row(
      children: [
        _buildStepIcon('assets/img/receipt-item.svg', true),
        _buildDashedLine(true),
        _buildStepIcon('assets/img/reserve.svg', true),
        _buildDashedLine(true),
        _buildStepIcon('assets/img/truck-fast.svg', true),
        _buildDashedLine(true),
        _buildStepIcon('assets/img/tick-circle.svg', true),
      ],
    );
  }

  Widget _buildDashedLine(bool active) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          SizedBox(width: 5),
          Container(
            width: 8,
            height: 8,
            transform: Matrix4.rotationZ(0.785398),
            decoration: BoxDecoration(
              color: active ? Color(0xFF26386A) : Color(0xFFE7E7E9),
              shape: BoxShape.rectangle,
            ),
          ),
          Row(
            children: List.generate(4, (index) {
              return Container(
                width: 3,
                height: 2,
                margin: EdgeInsets.symmetric(horizontal: 2),
                color: active ? Color(0xFF26386A) : Color(0xFFE7E7E9),
              );
            }),
          ),
          SizedBox(width: 7),
          Container(
            width: 8,
            height: 8,
            transform: Matrix4.rotationZ(0.785398),
            decoration: BoxDecoration(
              color: active ? Color(0xFF26386A) : Color(0xFFE7E7E9),
              shape: BoxShape.rectangle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIcon(String asset, bool active) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: active ? Color(0xFF26386A) : Color(0xFFE7E7E9),
        shape: BoxShape.circle,
      ),
      child: SvgPicture.asset(
        asset,
        width: 24,
        height: 24,
        color: Colors.white,
      ),
    );
  }

  Widget _buildActionIconPhone() {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Color(0xFFF5F5F5),
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.phone, color: Color(0xFF26386A)),
    );
  }

  Widget _buildActionIconMessage() {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Color(0xFFF5F5F5),
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.message, color: Color(0xFF26386A)),
    );
  }

  Widget _buildInfoTile(String title, String icon, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SvgPicture.asset(
            icon,
            width: 20,
            height: 20,
            color: Color(0xFF26386A),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 12, color: Color(0xFF9D9FA4)),
                ),
                SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF26386A),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}