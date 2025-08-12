import 'dart:convert';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show ScaffoldState;
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:mvc_pattern/mvc_pattern.dart';
// import 'package:geocoding/geocoding.dart';

import '../helpers/helper.dart';
import '../models/address.dart';
import '../models/category.dart';
import '../models/cuisine.dart';
import '../models/food.dart';
import '../models/restaurant.dart';
import '../models/review.dart';
import '../models/slide.dart';
// import '../repository/category_repository.dart';
import '../repository/home/get_categorizes_repository.dart';
import '../repository/home/get_cuisines_repository.dart';
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
  List<Cuisine> cuisines = <Cuisine>[];
  List<Slide> slides = <Slide>[];
  List<Restaurant> topRestaurants = <Restaurant>[];
  bool getPopularRestaurants = false;
  List<Restaurant> popularRestaurants = <Restaurant>[];
  List<Review> recentReviews = <Review>[];
  List<Food> trendingFoods = <Food>[];
  
  // إضافة متغيرات للمطاعم القريبة
  List<Restaurant> nearbyStores = <Restaurant>[];
  bool isLoadingNearbyStores = false;

  // Loading states
  bool isLoadingSlides = false;
  bool isLoadingCategories = false;
  bool isLoadingCuisines = false;
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
      final results = await Future.wait([
        getSlides(),
        getCuisines(),
        getTopRestaurants(),
        fetchPopularRestaurants(),
        getTrendingFoods(),
        getNearbyStores(), // إضافة جلب المطاعم القريبة
      ]);

      slides = results[0] as List<Slide>;
      cuisines = results[1] as List<Cuisine>;
      topRestaurants = results[2] as List<Restaurant>;
      popularRestaurants = results[3] as List<Restaurant>;
      trendingFoods = results[4] as List<Food>;
      nearbyStores = results[5] as List<Restaurant>; // إضافة المطاعم القريبة
      getPopularRestaurants = true;

      _isDataLoaded = true;

      await getCurrentLocation();
      print("Detected location: $currentLocationName");


      setState(() {});
    } catch (e) {
      print('Error loading all data: $e');
      rethrow;
    }
  }


  Future<void> refreshHome() async {
    _isDataLoaded = false;
    slides = [];
    categories = [];
    cuisines = [];
    topRestaurants = [];
    popularRestaurants = [];
    recentReviews = [];
    trendingFoods = [];
    nearbyStores = []; // إضافة مسح المطاعم القريبة

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

  Future<String?> getLocationNameWithLanguage(double lat, double lng) async {
    try {
      String languageCode = window.locale.languageCode;

      final url = Uri.https(
        'maps.googleapis.com',
        '/maps/api/geocode/json',
        {
          'latlng': '$lat,$lng',
          'language': languageCode,
          'key': 'AIzaSyDa5865xd383IlBX694cl6zPeCtzXQ6XPs',
        },
      );

      print('📡 Final URL: $url');

      final response = await http.get(url);

      print('📥 Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['results'] != null && data['results'].length > 0) {
          return data['results'][0]['formatted_address'];
        }
      }
    } catch (e) {
      print('❌ Error in getLocationNameWithLanguage: $e');
    }
    return null;
  }


  // Future<String?> getCurrentLocation() async {
  //   try {
  //     final hasPermission = await requestLocationPermission();
  //
  //     if (!hasPermission) {
  //       print('Location permission denied');
  //       return null;
  //     }
  //
  //     Position position = await Geolocator.getCurrentPosition(
  //       desiredAccuracy: LocationAccuracy.high,
  //     );
  //
  //     print("📍 Latitude: ${position.latitude}, Longitude: ${position.longitude}");
  //
  //     List<Placemark> placemarks = await placemarkFromCoordinates(
  //       position.latitude,
  //       position.longitude,
  //     );
  //
  //     if (placemarks.isNotEmpty) {
  //       Placemark place = placemarks[0];
  //
  //       String city = place.locality ?? place.subAdministrativeArea ?? '';
  //       String country = place.country ?? '';
  //
  //       String fullAddress = '$city, $country'.trim();
  //
  //       if (fullAddress.isEmpty) {
  //         print("⚠️ Placemark is empty: $place");
  //         fullAddress = "${position.latitude}, ${position.longitude}";
  //       }
  //
  //       setState(() {
  //         currentLocationName = fullAddress;
  //       });
  //
  //       print("📌 Place info: Name: $city, Country: $country");
  //       return currentLocationName;
  //     } else {
  //       print("⚠️ placemarks.isEmpty");
  //     }
  //
  //     return null;
  //   } catch (e) {
  //     print('❌ Error getting location: $e');
  //     return null;
  //   }
  // }

  Future<String?> getCurrentLocation() async {
    try {
      final hasPermission = await requestLocationPermission();

      if (!hasPermission) {
        print('❌ Location permission denied');
        return null;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      print("📍 Latitude: ${position.latitude}, Longitude: ${position.longitude}");

      String? address = await getLocationNameWithLanguage(position.latitude, position.longitude);

      if (address != null && address.isNotEmpty) {
        setState(() {
          currentLocationName = address;
        });

        print("📌 Detected Address: $address");
        return address;
      } else {
        print("⚠️ No address returned from Google API");
        return null;
      }
    } catch (e) {
      print('❌ Error getting location: $e');
      return null;
    }
  }

  Future<List<Restaurant>> getNearbyStores() async {
    setState(() {
      isLoadingNearbyStores = true;
    });

    try {
      // الحصول على موقع المستخدم الحالي
      Position? currentPosition;
      try {
        currentPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
      } catch (e) {
        print('❌ Error getting current position: $e');
      }

      // إنشاء Address object لموقع المستخدم
      Address userLocation = Address.fromJSON({
        'latitude': currentPosition?.latitude ?? 0.0,
        'longitude': currentPosition?.longitude ?? 0.0,
      });

      // جلب المطاعم القريبة
      final restaurantStreamFuture = getNearRestaurants(
        userLocation,
        userLocation, // استخدام نفس الموقع للمنطقة
      );
      
      final restaurantStream = await restaurantStreamFuture;
      final allRestaurants = await restaurantStream.toList();

      // تصفية المطاعم من نوع store
      final storeRestaurants = allRestaurants.where((restaurant) {
        return restaurant.restaurantType?.toLowerCase() == 'store' ||
               restaurant.name.toLowerCase().contains('store') ||
               restaurant.description.toLowerCase().contains('store');
      }).toList();

      // ترتيب المطاعم حسب القرب
      storeRestaurants.sort((a, b) {
        final distanceA = a.distance;
        final distanceB = b.distance;
        return distanceA.compareTo(distanceB);
      });

      setState(() {
        nearbyStores = storeRestaurants;
        isLoadingNearbyStores = false;
      });

      print("✅ تم جلب ${nearbyStores.length} مطعم قريب من نوع store");
      return nearbyStores;
    } catch (e) {
      print('❌ Error loading nearby stores: $e');
      setState(() {
        isLoadingNearbyStores = false;
      });
      return [];
    }
  }


}