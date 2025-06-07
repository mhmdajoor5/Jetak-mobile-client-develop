import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show ScaffoldState;
import 'package:geolocator/geolocator.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:geocoding/geocoding.dart';

import '../helpers/helper.dart';
import '../models/category.dart';
import '../models/food.dart';
import '../models/restaurant.dart';
import '../models/review.dart';
import '../models/slide.dart';
// import '../repository/category_repository.dart';
import '../repository/home/get_categorizes_repository.dart';
import '../repository/home/get_top_restorants_repo.dart';
import '../repository/home/get_trending_foods_repo.dart';
import '../repository/home/slider_repository.dart';
import '../repository/restaurant_repository.dart';
import '../repository/resturant/popular_reatauran_repository.dart';
import '../repository/settings_repository.dart';

class HomeController extends ControllerMVC {
  // Add scaffoldKey
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  List<Category> categories = <Category>[];
  List<Slide> slides = <Slide>[];
  List<Restaurant> topRestaurants = <Restaurant>[];
  bool getPopularRestaurants = false;
  List<Restaurant> popularRestaurants = <Restaurant>[];
  List<Review> recentReviews = <Review>[];
  List<Food> trendingFoods = <Food>[];
  
  // Loading states
  bool isLoadingSlides = false;
  bool isLoadingCategories = false;
  bool isLoadingTopRestaurants = false;
  bool isLoadingPopularRestaurants = false;
  bool isLoadingTrendingFoods = false;

  // Data loading completion state
  bool _isDataLoaded = false;

  // Getter for _isDataLoaded
  bool get isDataLoaded => _isDataLoaded;

  // Method to reset data loading state
  void resetDataLoading() {
    _isDataLoaded = false;
  }

  HomeController() {
    loadAllData();
  }

  Future<void> loadAllData() async {
    if (_isDataLoaded) return; // Skip if already loaded
    
    try {
      // Load all data in parallel
      final results = await Future.wait([
        getSlides(),
        getCategories(),
        getTopRestaurants(),
        fetchPopularRestaurants(),
        getTrendingFoods(),
      ]);

      // Update data directly without setState
      slides = results[0] as List<Slide>;
      categories = results[1] as List<Category>;
      topRestaurants = results[2] as List<Restaurant>;
      popularRestaurants = results[3] as List<Restaurant>;
      trendingFoods = results[4] as List<Food>;
      getPopularRestaurants = true;

      _isDataLoaded = true;
      setState(() {}); // Single UI update
    } catch (e) {
      print('Error loading all data: $e');
      rethrow;
    }
  }

  Future<void> refreshHome() async {
    _isDataLoaded = false;
    slides = [];
    categories = [];
    topRestaurants = [];
    popularRestaurants = [];
    recentReviews = [];
    trendingFoods = [];

    await loadAllData();
  }

  void requestForCurrentLocation(BuildContext context) {
    OverlayEntry loader = Helper.overlayLoader(context);
    Overlay.of(context).insert(loader);
    setCurrentLocation().then((_address) async {
      deliveryAddress.value = _address;
      await refreshHome();
      loader.remove();
    }).catchError((e) {
      loader.remove();
    });
  }

  // get the current location and store the address in new var and have init value = null
  String? currentLocationName = null;
  Future<bool> requestLocationPermission() async {
    print("Starting location permission request");

    // First check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    print("Location services enabled: $serviceEnabled");

    if (!serviceEnabled) {
      print("Location services are disabled - prompting user to enable");
      // Direct the user to enable location services
      bool enabled = await Geolocator.openLocationSettings();
      if (!enabled) {
        print("User didn't enable location services");
        return false;
      }
      // Check again after they return
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return false;
    }

    // Now check permissions
    LocationPermission permission = await Geolocator.checkPermission();
    print("Current permission status: $permission");

    if (permission == LocationPermission.deniedForever) {
      print("Permissions permanently denied - directing to app settings");
      // Direct user to app settings to enable permissions
      await Geolocator.openAppSettings();
      return false;
    }

    if (permission == LocationPermission.denied) {
      print("Requesting location permission");
      permission = await Geolocator.requestPermission();
      print("Permission after request: $permission");

      if (permission == LocationPermission.denied) {
        print("User denied permissions");
        return false;
      }
    }

    print("Location permission granted");
    return true;
  }
  Future<String?> getCurrentLocation() async {
    try {
      final hasPermission = await requestLocationPermission();

      if (!hasPermission) {
        print('Location permission denied');
        return null;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );


      // Get address from coordinates
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState((){
          currentLocationName = ' ${place.locality}, ${place.country}';
        });
        print(currentLocationName);
        return currentLocationName;
      }

      return null;
    } catch (e) {
      print('Error getting location: $e');
      return null;
    }
  }

// Usage example:
// String? location = await getCurrentLocation();
// print(currentLocationName); // Will contain the address


}
