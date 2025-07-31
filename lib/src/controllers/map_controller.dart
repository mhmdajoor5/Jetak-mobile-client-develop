import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:mvc_pattern/mvc_pattern.dart';

import '../helpers/app_config.dart' as config;
import '../helpers/helper.dart';
import '../helpers/maps_util.dart';
import '../models/address.dart';
import '../models/restaurant.dart';
import '../repository/restaurant_repository.dart';
import '../repository/settings_repository.dart' as sett;

// Standalone function for polyline calculation
Future<List<LatLng>> calculatePolyline({
  required Address currentAddress,
  required Restaurant restaurant,
  required String apiKey,
}) async {
  // Validate inputs
  if (currentAddress.latitude == null || 
      currentAddress.longitude == null ||
      restaurant.latitude == null || 
      restaurant.longitude == null ||
      apiKey.isEmpty) {
    print("Invalid parameters for polyline calculation");
    return [];
  }

  // Validate coordinates
  double? currentLat = currentAddress.latitude;
  double? currentLng = currentAddress.longitude;
  double? restaurantLat = double.tryParse(restaurant.latitude ?? '');
  double? restaurantLng = double.tryParse(restaurant.longitude ?? '');

  if (currentLat == null || currentLng == null || 
      restaurantLat == null || restaurantLng == null) {
    print("Invalid coordinate values");
    return [];
  }

  final mapsUtil = MapsUtil();
  final query = "origin=$currentLat,$currentLng"
      "&destination=$restaurantLat,$restaurantLng"
      "&key=$apiKey";

  try {
    final result = await mapsUtil.get(query);
    return result ?? [];
  } catch (e) {
    print("Error in calculatePolyline: $e");
    return [];
  }
}

class MapController extends ControllerMVC {
  late Restaurant currentRestaurant = Restaurant(id: 'all');
  List<Restaurant> topRestaurants = <Restaurant>[];
  List<Marker> allMarkers = <Marker>[];
  late Address currentAddress;
  Set<Polyline> polylines = {};
  late CameraPosition? cameraPosition;
  final MapsUtil mapsUtil = MapsUtil();
  final Completer<GoogleMapController> mapController = Completer();
  Timer? cameraMoveTimer;
  bool _isLoading = false;
  Timer? _debounceTimer;

  void listenForNearRestaurants(Address myLocation, Address areaLocation) async {
    if (_isLoading) return;
    _isLoading = true;

    try {
      print('Loading restaurants for area: ${areaLocation.latitude}, ${areaLocation.longitude}');
      final Stream<Restaurant> stream = await getNearRestaurants(myLocation, areaLocation);
      final List<Restaurant> batch = [];
      final List<Marker> markerBatch = [];
      int restaurantCount = 0;

      await for (Restaurant restaurant in stream) {
        if (restaurant.id.isNotEmpty && restaurant.name.isNotEmpty) {
          batch.add(restaurant);
          final marker = await Helper.getMarker(restaurant.toMap());
          markerBatch.add(marker);
          restaurantCount++;

          // Update UI more frequently for better UX
          if (batch.length % 3 == 0) {
            setState(() {
              topRestaurants.addAll(batch);
              allMarkers.addAll(markerBatch);
              batch.clear();
              markerBatch.clear();
            });
          }
        }
      }

      if (batch.isNotEmpty) {
        setState(() {
          topRestaurants.addAll(batch);
          allMarkers.addAll(markerBatch);
        });
      }

      print('Loaded $restaurantCount restaurants on map');
      if (restaurantCount == 0) {
        print('No restaurants found in this area');
      }
    } catch (e) {
      print('Error loading nearby restaurants: $e');
    } finally {
      _isLoading = false;
    }
  }

  void getCurrentLocation() async {
    try {
      currentAddress = sett.deliveryAddress.value;
      setState(() {
        cameraPosition = currentAddress.isUnknown()
            ? CameraPosition(target: LatLng(40, 3), zoom: 4)
            : CameraPosition(
            target: LatLng(currentAddress.latitude ?? 0.0, currentAddress.longitude ?? 0.0),
            zoom: 14.4746);
      });

      if (!currentAddress.isUnknown()) {
        final marker = await Helper.getMyPositionMarker(
          currentAddress.latitude ?? 0.0,
          currentAddress.longitude ?? 0.0,
        );
        setState(() {
          // Remove any existing user position marker first
          allMarkers.removeWhere((m) => m.markerId.value == 'my_position');
          allMarkers.add(marker);
        });
        
        // Load nearby restaurants after setting location
        getRestaurantsOfArea();
      }
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        print('Permission denied');
      }
    }
  }

  void getRestaurantLocation() async {
    try {
      currentAddress = await sett.getCurrentLocation();
      setState(() {
        cameraPosition = CameraPosition(
          target: LatLng(
            double.tryParse(currentRestaurant.latitude ?? '') ?? 0.0,
            double.tryParse(currentRestaurant.longitude ?? '') ?? 0.0,
          ),
          zoom: 14.4746,
        );
      });

      if (!currentAddress.isUnknown()) {
        final marker = await Helper.getMyPositionMarker(
          currentAddress.latitude ?? 0.0,
          currentAddress.longitude ?? 0.0,
        );
        setState(() => allMarkers.add(marker));
      }
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        print('Permission denied');
      }
    }
  }

  Future<void> goCurrentLocation() async {
    final controller = await mapController.future;
    final newAddress = await sett.setCurrentLocation();
    setState(() {
      sett.deliveryAddress.value = newAddress;
      currentAddress = newAddress;
    });
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(newAddress.latitude, newAddress.longitude),
          zoom: 14.4746,
        ),
      ),
    );
  }

  void onCameraMove(CameraPosition position) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 1000), () {
      getRestaurantsOfArea();
    });
    cameraPosition = position;
  }

  void getRestaurantsOfArea() {
    if (cameraPosition == null || _isLoading) return;

    // Only clear markers that are not the user's position
    setState(() {
      topRestaurants.clear();
      // Keep the user position marker and only clear restaurant markers
      allMarkers.removeWhere((marker) => marker.markerId.value != 'my_position');
    });

    final areaAddress = Address.fromJSON({
      "latitude": cameraPosition!.target.latitude,
      "longitude": cameraPosition!.target.longitude,
    });
    listenForNearRestaurants(currentAddress, areaAddress);
  }

  Future<void> getDirectionSteps() async {
    try {
      currentAddress = await sett.getCurrentLocation();
      if (currentAddress.isUnknown()) {
        print("Current address is unknown, cannot get directions");
        return;
      }

      // Validate API key
      String apiKey = sett.setting.value.googleMapsKey ?? '';
      if (apiKey.isEmpty) {
        print("Google Maps API key is empty");
        return;
      }

      // Validate restaurant coordinates
      if (currentRestaurant.latitude == null || currentRestaurant.longitude == null) {
        print("Restaurant coordinates are null");
        return;
      }

      print("Getting directions from ${currentAddress.latitude},${currentAddress.longitude} to ${currentRestaurant.latitude},${currentRestaurant.longitude}");

      // Use compute for heavy calculation
      final polylineData = <String, dynamic>{
        'currentAddress': currentAddress.toMap(), // Convert to map for compute
        'restaurant': currentRestaurant.toMap(),
        'apiKey': apiKey,
      };

      final polylinePoints = await compute(_calculatePolylineInIsolate, polylineData);

      if (polylinePoints.isNotEmpty) {
        // Add starting point
        polylinePoints.insert(0, LatLng(
          currentAddress.latitude ?? 0.0,
          currentAddress.longitude ?? 0.0,
        ));

        setState(() {
          polylines.clear(); // Clear existing polylines
          polylines.add(Polyline(
            visible: true,
            polylineId: PolylineId(currentAddress.hashCode.toString()),
            points: polylinePoints,
            color: config.Colors().mainColor(0.8),
            width: 6,
          ));
        });
        
        print("Successfully added polyline with ${polylinePoints.length} points");
      } else {
        print("No polyline points received");
      }
    } catch (e) {
      print('Error calculating polyline: $e');
      // Optionally show user-friendly error message
    }
  }

  Future<void> refreshMap() async {
    setState(() => topRestaurants.clear());
    listenForNearRestaurants(currentAddress, currentAddress);
  }

  @override
  void dispose() {
    cameraMoveTimer?.cancel();
    _debounceTimer?.cancel();
    mapController.future.then((controller) => controller.dispose());
    super.dispose();
  }
}

// Isolate function for compute
Future<List<LatLng>> _calculatePolylineInIsolate(Map<String, dynamic> data) async {
  final currentAddress = Address.fromJSON(data['currentAddress']);
  final restaurant = Restaurant.fromJSON(data['restaurant']);
  final apiKey = data['apiKey'] as String;

  return await calculatePolyline(
    currentAddress: currentAddress,
    restaurant: restaurant,
    apiKey: apiKey,
  );
}




class ApiKeyTester {
  static const String API_KEY = "AIzaSyC6GK6c5IMopZIMo_F1btLZgYY4HTIuPLg";
  
  // Test different APIs to see which ones work
  static Future<void> testAllAPIs() async {
    print("=== Testing Google Maps APIs ===");
    
    // Test 1: Simple Directions API
    await testDirectionsAPI();
    
    // Test 2: Geocoding API
    await testGeocodingAPI();
    
    // Test 3: Places API
    await testPlacesAPI();
    
    // Test 4: Maps Static API
    await testStaticMapsAPI();
  }
  
  static Future<void> testDirectionsAPI() async {
    print("\n--- Testing Directions API ---");
    
    // Test with simple coordinates (New York to Boston)
    final testUrl = "https://maps.googleapis.com/maps/api/directions/json?"
        "origin=40.7128,-74.0060"
        "&destination=42.3601,-71.0589"
        "&key=$API_KEY";
    
    try {
      final response = await http.get(Uri.parse(testUrl));
      final data = jsonDecode(response.body);
      
      print("Status Code: ${response.statusCode}");
      print("API Status: ${data['status']}");
      
      if (data['status'] == 'OK') {
        print("✅ Directions API: Working");
        print("Routes found: ${data['routes']?.length ?? 0}");
      } else {
        print("❌ Directions API: Failed");
        print("Error: ${data['error_message'] ?? 'No error message'}");
        
        // Check specific error types
        switch (data['status']) {
          case 'REQUEST_DENIED':
            print("🔑 API Key issue - Check restrictions and enabled APIs");
            break;
          case 'ZERO_RESULTS':
            print("📍 No route found between points");
            break;
          case 'OVER_QUERY_LIMIT':
            print("💰 Quota exceeded");
            break;
          case 'INVALID_REQUEST':
            print("📝 Invalid request parameters");
            break;
        }
      }
    } catch (e) {
      print("❌ Network Error: $e");
    }
  }
  
  static Future<void> testGeocodingAPI() async {
    print("\n--- Testing Geocoding API ---");
    
    final testUrl = "https://maps.googleapis.com/maps/api/geocode/json?"
        "latlng=40.7128,-74.0060"
        "&key=$API_KEY";
    
    try {
      final response = await http.get(Uri.parse(testUrl));
      final data = jsonDecode(response.body);
      
      print("Status Code: ${response.statusCode}");
      print("API Status: ${data['status']}");
      
      if (data['status'] == 'OK') {
        print("✅ Geocoding API: Working");
      } else {
        print("❌ Geocoding API: Failed");
        print("Error: ${data['error_message'] ?? 'No error message'}");
      }
    } catch (e) {
      print("❌ Network Error: $e");
    }
  }
  
  static Future<void> testPlacesAPI() async {
    print("\n--- Testing Places API ---");
    
    final testUrl = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?"
        "location=40.7128,-74.0060"
        "&radius=1000"
        "&type=restaurant"
        "&key=$API_KEY";
    
    try {
      final response = await http.get(Uri.parse(testUrl));
      final data = jsonDecode(response.body);
      
      print("Status Code: ${response.statusCode}");
      print("API Status: ${data['status']}");
      
      if (data['status'] == 'OK') {
        print("✅ Places API: Working");
      } else {
        print("❌ Places API: Failed");
        print("Error: ${data['error_message'] ?? 'No error message'}");
      }
    } catch (e) {
      print("❌ Network Error: $e");
    }
  }
  
  static Future<void> testStaticMapsAPI() async {
    print("\n--- Testing Static Maps API ---");
    
    final testUrl = "https://maps.googleapis.com/maps/api/staticmap?"
        "center=40.7128,-74.0060"
        "&zoom=13"
        "&size=300x300"
        "&key=$API_KEY";
    
    try {
      final response = await http.get(Uri.parse(testUrl));
      
      print("Status Code: ${response.statusCode}");
      
      if (response.statusCode == 200) {
        print("✅ Static Maps API: Working");
      } else {
        print("❌ Static Maps API: Failed");
        print("Response: ${response.body}");
      }
    } catch (e) {
      print("❌ Network Error: $e");
    }
  }
  
  // Test with your actual coordinates
  static Future<void> testWithActualCoordinates({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
  }) async {
    print("\n--- Testing with Actual App Coordinates ---");
    print("Origin: $originLat, $originLng");
    print("Destination: $destLat, $destLng");
    
    final testUrl = "https://maps.googleapis.com/maps/api/directions/json?"
        "origin=$originLat,$originLng"
        "&destination=$destLat,$destLng"
        "&key=$API_KEY";
    
    try {
      final response = await http.get(Uri.parse(testUrl));
      final data = jsonDecode(response.body);
      
      print("Status Code: ${response.statusCode}");
      print("API Status: ${data['status']}");
      print("Full Response: ${response.body}");
      
      if (data['status'] == 'OK') {
        print("✅ Your coordinates work!");
      } else {
        print("❌ Your coordinates failed");
        print("Error: ${data['error_message'] ?? 'No error message'}");
      }
    } catch (e) {
      print("❌ Network Error: $e");
    }
  }
}