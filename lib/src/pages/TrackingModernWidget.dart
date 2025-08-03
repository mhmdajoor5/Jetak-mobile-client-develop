import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'dart:convert';
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

  // Enhanced method to get the route polyline with better error handling
  _getPolyline() async {
    try {
      setState(() {
        _isLoadingRoute = true;
        _routeError = null;
      });

      print("=== Starting Route Calculation ===");
      
      // تحديث إحداثيات المطعم والمستخدم في الـ controller أولاً
      _updateControllerCoordinates();
      
      // استخراج الإحداثيات الفعلية من الطلب
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
        }
        clientLat = _con.order.deliveryAddress.latitude;
        clientLng = _con.order.deliveryAddress.longitude;
      } catch (e) {
        print("Error extracting coordinates: $e");
      }

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

      polylineCoordinates = result.points
          .map((point) => LatLng(point.latitude, point.longitude))
          .toList();

      print("Successfully got ${polylineCoordinates.length} route points");
      _addPolyline();

    } catch (e) {
      print("Error in _getPolyline: $e");
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
    } finally {
      if (mounted) {
        setState(() => _isLoadingRoute = false);
      }
    }
  }

  // Test the Directions API directly to diagnose issues
  Future<void> _testDirectionsAPI(double restaurantLat, double restaurantLng, double clientLat, double clientLng) async {
    final url = "https://maps.googleapis.com/maps/api/directions/json?"
        "origin=$restaurantLat,$restaurantLng"
        "&destination=$clientLat,$clientLng"
        "&key=$_apiKey";

    print("Testing Directions API: $url");

    try {
      final response = await http.get(Uri.parse(url)).timeout(
        Duration(seconds: 15),
        onTimeout: () => throw Exception("Request timeout"),
      );

      print("Direct API Response Status: ${response.statusCode}");
      
      if (response.statusCode != 200) {
        throw Exception("HTTP ${response.statusCode}: ${response.body}");
      }

      final data = jsonDecode(response.body);
      print("Direct API Response Status: ${data['status']}");
      
      if (data['status'] != 'OK') {
        String errorMsg = data['error_message'] ?? "Unknown API error";
        throw Exception("Directions API Error: ${data['status']} - $errorMsg");
      }

      print("✅ Direct API test successful");
      
    } catch (e) {
      print("❌ Direct API test failed: $e");
      throw e;
    }
  }

  // Method to add polyline to the map
  _addPolyline() {
    try {
      if (polylineCoordinates.isEmpty) {
        throw Exception("No coordinates to draw polyline");
      }

      final id = PolylineId("route_${DateTime.now().millisecondsSinceEpoch}");
      final polyline = Polyline(
        polylineId: id,
        color: Color(0xFF26386A), // Match your app theme
        points: polylineCoordinates,
        width: 5,
        geodesic: true,
        patterns: [], // Solid line
      );

      setState(() {
        polylines = {id: polyline}; // Replace existing polylines
      });

      // Zoom to fit the route with some delay to ensure map is ready
      Future.delayed(Duration(milliseconds: 500), () {
        if (_mapController != null && polylineCoordinates.isNotEmpty) {
          _mapController!.animateCamera(
            CameraUpdate.newLatLngBounds(
              _boundsFromLatLngList(polylineCoordinates),
              100.0, // increased padding
            ),
          );
        }
      });

      print("✅ Polyline added successfully with ${polylineCoordinates.length} points");
    } catch (e) {
      print("❌ Error in _addPolyline: $e");
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

  @override
  void initState() {
    super.initState();
    if (widget.routeArgument != null && widget.routeArgument!.id != null) {
      _con.listenForOrder(orderId: widget.routeArgument!.id!);
      _con.getOrderDetailsTracking(orderId: widget.routeArgument!.id!);
    }
    loadMotorcycleIcon();
    // Delay route calculation to ensure order data is loaded
    Future.delayed(Duration(milliseconds: 2000), () {
      if (mounted) {
        _updateControllerCoordinates();
        _getPolyline();
      }
    });
  }

  // دالة لتحديث إحداثيات المطعم والمستخدم في الـ controller
  void _updateControllerCoordinates() {
    try {
      // استخراج إحداثيات المطعم من الطلب
      if (_con.order.foodOrders.isNotEmpty) {
        double? restaurantLat = double.tryParse(
          _con.order.foodOrders[0].food?.restaurant.latitude ?? '',
        );
        double? restaurantLng = double.tryParse(
          _con.order.foodOrders[0].food?.restaurant.longitude ?? '',
        );
        
        if (restaurantLat != null && restaurantLng != null && 
            restaurantLat != 0.0 && restaurantLng != 0.0) {
          _con.restaurantLocation = LatLng(restaurantLat, restaurantLng);
          print("✅ Updated restaurant location: $_con.restaurantLocation");
        }
      }
      
      // استخراج إحداثيات العميل من العنوان
      double? clientLat = _con.order.deliveryAddress.latitude;
      double? clientLng = _con.order.deliveryAddress.longitude;
      
      if (clientLat != null && clientLng != null && 
          clientLat != 0.0 && clientLng != 0.0) {
        _con.clientLocation = LatLng(clientLat, clientLng);
        print("✅ Updated client location: $_con.clientLocation");
      }
      
    } catch (e) {
      print("❌ Error updating coordinates: $e");
    }
  }

  BitmapDescriptor? motorcycleIcon;

  Future<void> loadMotorcycleIcon() async {
    try {
      motorcycleIcon = await BitmapDescriptor.asset(
        ImageConfiguration(size: Size(48, 48)),
        'assets/img/pointer.png',
      );
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print("Error loading motorcycle icon: $e");
      // Use default marker as fallback
    }
  }

  @override
  Widget build(BuildContext context) {
    print('Order ID: ${widget.routeArgument?.id}');
    print('Food Orders Length: ${_con.order.foodOrders.length}');
    print('Address: ${_con.order.deliveryAddress.address}');

    // Show loading screen if order data is not ready
    if (_con.order.id == null || _con.order.foodOrders.isEmpty) {
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
            ],
          ),
        ),
      );
    }

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

    // Build markers - بناء العلامات المتوفرة فقط
    Set<Marker> markers = {};
    
    // Add restaurant marker if coordinates are available
    if (hasRestaurantCoords) {
      if (motorcycleIcon != null) {
        markers.add(
          Marker(
            markerId: MarkerId('restaurant'),
            position: LatLng(restaurantLat!, restaurantLng!),
            infoWindow: InfoWindow(title: 'Restaurant'),
            icon: motorcycleIcon!,
          ),
        );
      } else {
        markers.add(
          Marker(
            markerId: MarkerId('restaurant'),
            position: LatLng(restaurantLat!, restaurantLng!),
            infoWindow: InfoWindow(title: 'Restaurant'),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          ),
        );
      }
    }

    // Add client marker if coordinates are available
    if (hasClientCoords) {
      markers.add(
        Marker(
          markerId: MarkerId('client'),
          position: LatLng(clientLat!, clientLng!),
          infoWindow: InfoWindow(title: 'Delivery Address'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );
    }

    // Calculate camera position based on available coordinates
    LatLng cameraTarget;
    double zoom = 12;
    
    if (hasRestaurantCoords && hasClientCoords) {
      // Both coordinates available - center between them
      cameraTarget = LatLng(
        (restaurantLat! + clientLat!) / 2,
        (restaurantLng! + clientLng!) / 2,
      );
      zoom = 12;
    } else if (hasRestaurantCoords) {
      // Only restaurant coordinates available
      cameraTarget = LatLng(restaurantLat!, restaurantLng!);
      zoom = 14;
    } else {
      // Only client coordinates available
      cameraTarget = LatLng(clientLat!, clientLng!);
      zoom = 14;
    }

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
          
          // Error overlay
          if (_routeError != null)
            Positioned(
              top: 20,
              left: 20,
              right: 20,
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Route Loading Failed",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.red.shade800,
                            ),
                          ),
                          Text(
                            _routeError!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.red.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: _getPolyline,
                      child: Text("Retry"),
                    ),
                  ],
                ),
              ),
            ),
          
          // Bottom sheet
          _buildBottomSheet(),
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

  Widget _buildBottomSheet() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Color(0xFFEDEDED),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
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
                _buildActionIconPhone(),
                SizedBox(width: 10),
                Stack(
                  children: [
                    _buildActionIconMessage(),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: CircleAvatar(
                        radius: 8,
                        backgroundColor: Colors.red,
                        child: Text(
                          "3",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),
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
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: _buildStepProgress(_con.order.orderStatus.id),
            ),
            SizedBox(height: 20),
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
          ],
        ),
      ),
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