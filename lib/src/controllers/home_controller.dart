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
import '../repository/order/order_track_repo.dart';
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
    if (_isDataLoaded) return;
    try {
      // Load critical data first (slides and categories)
      final criticalResults = await Future.wait([
        getSlides(),
        getCategories(),
      ]).timeout(const Duration(seconds: 5));

      slides = criticalResults[0] as List<Slide>;
      categories = criticalResults[1] as List<Category>;

      // Update UI with critical data first
      setState(() {});

      // Load restaurant data in background
      final restaurantResults = await Future.wait([
        getTopRestaurants(),
        fetchPopularRestaurants(),
        getTrendingFoods(),
      ]).timeout(const Duration(seconds: 10));

      topRestaurants = restaurantResults[0] as List<Restaurant>;
      popularRestaurants = restaurantResults[1] as List<Restaurant>;
      trendingFoods = restaurantResults[2] as List<Food>;
      getPopularRestaurants = true;

      _isDataLoaded = true;

      // Get location in background without blocking UI
      getCurrentLocation().catchError((e) {
        print('Location error: $e');
      });

      setState(() {});
    } catch (e) {
      print('Error loading all data: $e');
      // Don't rethrow to avoid splash screen hanging
      _isDataLoaded = true;
    }
  }


  Future<void> refreshHome() async {
    try {
      _isDataLoaded = false;
      slides = [];
      categories = [];
      topRestaurants = [];
      popularRestaurants = [];
      recentReviews = [];
      trendingFoods = [];

      await loadAllData();
    } catch (e) {
      print('Error refreshing home: $e');
      // Ensure UI doesn't hang on refresh errors
      setState(() {});
    }
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

  String? currentLocationName = null;
  Future<bool> requestLocationPermission() async {
    print("Starting location permission request");

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    print("Location services enabled: $serviceEnabled");

    if (!serviceEnabled) {
      print("Location services are disabled - prompting user to enable");
      bool enabled = await Geolocator.openLocationSettings();
      if (!enabled) {
        print("User didn't enable location services");
        return false;
      }
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    print("Current permission status: $permission");

    if (permission == LocationPermission.deniedForever) {
      print("Permissions permanently denied - directing to app settings");
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

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      print("📍 Latitude: ${position.latitude}, Longitude: ${position.longitude}");

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];

        String city = place.locality ?? place.subAdministrativeArea ?? '';
        String country = place.country ?? '';

        String fullAddress = '$city, $country'.trim();

        if (fullAddress.isEmpty) {
          print("⚠️ Placemark is empty: $place");
          fullAddress = "${position.latitude}, ${position.longitude}";
        }

        setState(() {
          currentLocationName = fullAddress;
        });

        print("📌 Place info: Name: $city, Country: $country");
        return currentLocationName;
      } else {
        print("⚠️ placemarks.isEmpty");
      }

      return null;
    } catch (e) {
      print('❌ Error getting location: $e');
      return null;
    }
  }


}
