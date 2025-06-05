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
  late Restaurant currentRestaurant = Restaurant(id: '-50');
  List<Restaurant> topRestaurants = <Restaurant>[];
  List<Marker> allMarkers = <Marker>[];
  late Address currentAddress;
  Set<Polyline> polylines = {};
  late CameraPosition? cameraPosition;
  final MapsUtil mapsUtil = MapsUtil();
  final Completer<GoogleMapController> mapController = Completer();
  Timer? cameraMoveTimer;
  bool _isLoading = false;

  void listenForNearRestaurants(Address myLocation, Address areaLocation) async {
    if (_isLoading) return;
    _isLoading = true;

    final Stream<Restaurant> stream = await getNearRestaurants(myLocation, areaLocation);
    final List<Restaurant> batch = [];
    final List<Marker> markerBatch = [];

    await for (Restaurant restaurant in stream) {
      batch.add(restaurant);
      final marker = await Helper.getMarker(restaurant.toMap());
      markerBatch.add(marker);

      if (batch.length % 5 == 0) {
        setState(() {
          topRestaurants.addAll(batch);
          allMarkers.addAll(markerBatch);
          batch.clear();
          markerBatch.clear();
        });
      }
    }

    if (batch.isNotEmpty) {
      setState(() {
        topRestaurants.addAll(batch);
        allMarkers.addAll(markerBatch);
      });
    }
    _isLoading = false;
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
        setState(() => allMarkers.add(marker));
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
    cameraMoveTimer?.cancel();
    cameraMoveTimer = Timer(const Duration(milliseconds: 800), () {
      getRestaurantsOfArea();
    });
    cameraPosition = position;
  }

  void getRestaurantsOfArea() {
    if (cameraPosition == null) return;

    setState(() {
      topRestaurants.clear();
      allMarkers.clear();
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
    mapController.future.then((controller) => controller.dispose());
    super.dispose();
  }
}