import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:geocoding/geocoding.dart';

import '../helpers/helper.dart';
import '../models/category.dart';
import '../models/food.dart';
import '../models/restaurant.dart';
import '../models/review.dart';
import '../models/slide.dart';
import '../repository/category_repository.dart';
import '../repository/home/get_trending_foods_repo.dart';
import '../repository/home/slider_repository.dart';
import '../repository/restaurant_repository.dart';
import '../repository/resturant/popular_reatauran_repository.dart';
import '../repository/settings_repository.dart';

class HomeController extends ControllerMVC {
  List<Category> categories = <Category>[];
  List<Slide> slides = <Slide>[];
  List<Restaurant> topRestaurants = <Restaurant>[];
  bool getPopularRestaurants = false;
  List<Restaurant> popularRestaurants = <Restaurant>[];
  List<Review> recentReviews = <Review>[];
  List<Food> trendingFoods = <Food>[];

  HomeController() {
    listenForTopRestaurants();
    listenForSlides();
    listenForTrendingFoods();
    listenForCategories();
    listenForPopularRestaurants();
    listenForRecentReviews();
  }

  Future<void> listenForSlides() async {
    print("mElkerm Strart to fetch the slides in the controller");

    try {
      final List<Slide> data = (await getSlides());
      setState(() {
        slides = data;
        print("mElkerm get the sliders in the controller");

      });
    } catch (e) {
      print("mElkerm Error loading slides: $e");
    }

    // final Stream<Slide> stream = await getSlides();
    // stream.listen((Slide _slide) {
    //   setState(() => slides.add(_slide));
    // }, onError: (a) {
    //   print(a);
    // }, onDone: () {});
  }

  Future<void> listenForCategories() async {
    final Stream<Category> stream = await getCategories();
    stream.listen((Category _category) {
      setState(() => categories.add(_category));
    }, onError: (a) {
      print(a);
    }, onDone: () {});
  }

  Future<void> listenForTopRestaurants() async {
    final Stream<Restaurant> stream = await getNearRestaurants(deliveryAddress.value, deliveryAddress.value);
    stream.listen((Restaurant _restaurant) {
      setState(() => topRestaurants.add(_restaurant));
    }, onError: (a) {}, onDone: () {});
  }

  /// cahnge the stream to single request based on new repository
  Future<void> listenForPopularRestaurants() async {
    getPopularRestaurants = false;
    popularRestaurants = await fetchPopularRestaurants().then((onValue){
      getPopularRestaurants = true;
      return onValue;
    }).catchError((error) {
      print("Error fetching popular restaurants: $error");
      return <Restaurant>[];
    });
    setState((){});

    // final Stream<Restaurant> stream = await getPopularRestaurants(deliveryAddress.value);
    // stream.listen((Restaurant _restaurant) {
    //   setState(() => popularRestaurants.add(_restaurant));
    // }, onError: (a) {}, onDone: () {});
  }

  Future<void> listenForRecentReviews() async {
    final Stream<Review> stream = await getRecentReviews();
    stream.listen((Review _review) {
      setState(() => recentReviews.add(_review));
    }, onError: (a) {}, onDone: () {});
  }

  Future<void> listenForTrendingFoods() async {


    try {
      final List<Food> foods = await getTrendingFoods();
      setState(() {
        trendingFoods = foods;
      });
    } catch (e) {
      print('Error loading trending foods: $e');
    }

    // final Stream<Food> stream = await getTrendingFoods(deliveryAddress.value);
    // stream.listen((Food _food) {
    //   setState(() => trendingFoods.add(_food));
    // }, onError: (a) {
    //   print(a);
    // }, onDone: () {});
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

  Future<void> refreshHome() async {
    setState(() {
      slides = <Slide>[];
      categories = <Category>[];
      topRestaurants = <Restaurant>[];
      popularRestaurants = <Restaurant>[];
      recentReviews = <Review>[];
      trendingFoods = <Food>[];
    });
    ///mElkerm here i need 5 apis
    await listenForSlides();
    await listenForPopularRestaurants();

    await listenForTrendingFoods();
    await listenForTopRestaurants();
    await listenForCategories();
    await listenForRecentReviews();
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
