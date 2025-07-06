import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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
  final mapsUtil = MapsUtil();
  final query =
      "origin=${currentAddress.latitude},${currentAddress.longitude}"
      "&destination=${restaurant.latitude},${restaurant.longitude}"
      "&key=$apiKey";

  final result = await mapsUtil.get(query);
  return result ?? [];
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
            double.tryParse(currentRestaurant.latitude) ?? 0.0,
            double.tryParse(currentRestaurant.longitude) ?? 0.0,
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
    currentAddress = await sett.getCurrentLocation();
    if (currentAddress.isUnknown()) return;

    try {
      final polyline = await compute(
        calculatePolyline as ComputeCallback<Map<String, Object>, dynamic>,
        {
          'currentAddress': currentAddress,
          'restaurant': currentRestaurant,
          'apiKey': sett.setting.value.googleMapsKey,
        },
      );

      if (polyline.isNotEmpty) {
        polyline.insert(0, LatLng(
          currentAddress.latitude ?? 0.0,
          currentAddress.longitude ?? 0.0,
        ));

        setState(() {
          polylines.add(Polyline(
            visible: true,
            polylineId: PolylineId(currentAddress.hashCode.toString()),
            points: polyline,
            color: config.Colors().mainColor(0.8),
            width: 6,
          ));
        });
      }
    } catch (e) {
      print('Error calculating polyline: $e');
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