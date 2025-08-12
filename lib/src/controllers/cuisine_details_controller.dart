import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../models/cuisine.dart';
import '../models/restaurant.dart';
import '../repository/cuisine_details_repository.dart';

class CuisineDetailsController extends ControllerMVC {
  late GlobalKey<ScaffoldState> scaffoldKey;
  
  Cuisine? cuisine;
  List<Restaurant> restaurants = [];
  bool isLoading = true;
  String? errorMessage;

  CuisineDetailsController() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
  }

  Future<void> loadCuisineDetails(String cuisineId) async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final cuisineDetails = await getCuisineDetails(cuisineId);
      
      setState(() {
        cuisine = cuisineDetails.cuisine;
        restaurants = cuisineDetails.restaurants;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> refreshCuisineDetails(String cuisineId) async {
    await loadCuisineDetails(cuisineId);
  }
} 