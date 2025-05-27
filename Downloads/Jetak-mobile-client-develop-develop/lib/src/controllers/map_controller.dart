import 'dart:async';
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

class MapController extends ControllerMVC {
  late Restaurant currentRestaurant;
  List<Restaurant> topRestaurants = <Restaurant>[];
  List<Marker> allMarkers = <Marker>[];
  late Address currentAddress;
  Set<Polyline> polylines = {};
  late CameraPosition cameraPosition;
  final MapsUtil mapsUtil = MapsUtil();
  final Completer<GoogleMapController> mapController = Completer();

  void listenForNearRestaurants(Address myLocation, Address areaLocation) async {
    final Stream<Restaurant> stream = await getNearRestaurants(myLocation, areaLocation);
    stream.listen((restaurant) async {
      setState(() => topRestaurants.add(restaurant));
      final marker = await Helper.getMarker(restaurant.toMap());
      setState(() => allMarkers.add(marker));
    });
  }

  void getCurrentLocation() async {
    try {
      currentAddress = sett.deliveryAddress.value;
      setState(() {
        cameraPosition =
            currentAddress.isUnknown()
                ? CameraPosition(target: LatLng(40, 3), zoom: 4)
                : CameraPosition(target: LatLng(currentAddress.latitude ?? 0.0, currentAddress.longitude ?? 0.0), zoom: 14.4746);
      });
      if (!currentAddress.isUnknown()) {
        final marker = await Helper.getMyPositionMarker(currentAddress.latitude ?? 0.0, currentAddress.longitude ?? 0.0);
        setState(() => allMarkers.add(marker));
      }
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') print('Permission denied');
    }
  }

  void getRestaurantLocation() async {
    try {
      currentAddress = await sett.getCurrentLocation();
      setState(() {
        cameraPosition = CameraPosition(target: LatLng(double.tryParse(currentRestaurant.latitude) ?? 0.0, double.tryParse(currentRestaurant.longitude) ?? 0.0), zoom: 14.4746);
      });
      if (!currentAddress.isUnknown()) {
        final marker = await Helper.getMyPositionMarker(currentAddress.latitude ?? 0.0, currentAddress.longitude ?? 0.0);
        setState(() => allMarkers.add(marker));
      }
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') print('Permission denied');
    }
  }

  Future<void> goCurrentLocation() async {
    final controller = await mapController.future;
    final newAddress = await sett.setCurrentLocation();
    setState(() {
      sett.deliveryAddress.value = newAddress;
      currentAddress = newAddress;
    });
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: LatLng(newAddress.latitude, newAddress.longitude), zoom: 14.4746)));
  }

  void getRestaurantsOfArea() {
    setState(() {
      topRestaurants.clear();
      final areaAddress = Address.fromJSON({"latitude": cameraPosition.target.latitude, "longitude": cameraPosition.target.longitude});
      listenForNearRestaurants(currentAddress, areaAddress);
    });
  }

  void getDirectionSteps() async {
    currentAddress = await sett.getCurrentLocation();
    if (currentAddress.isUnknown()) return;

    final query =
        "origin=${currentAddress.latitude},${currentAddress.longitude}"
        "&destination=${currentRestaurant.latitude},${currentRestaurant.longitude}"
        "&key=${sett.setting.value?.googleMapsKey}";

    final res = await mapsUtil.get(query);
    if (res != null && res is List<LatLng>) {
      res.insert(0, LatLng(currentAddress.latitude ?? 0.0, currentAddress.longitude ?? 0.0));
      setState(() {
        polylines.add(Polyline(visible: true, polylineId: PolylineId(currentAddress.hashCode.toString()), points: res, color: config.Colors().mainColor(0.8), width: 6));
      });
    }
  }

  Future<void> refreshMap() async {
    setState(() => topRestaurants.clear());
    listenForNearRestaurants(currentAddress, currentAddress);
  }
}
