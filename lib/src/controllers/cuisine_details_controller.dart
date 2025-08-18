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

  // Helper methods for cuisine type
  bool get isStoreType => cuisine?.type == 'store';
  bool get isRestaurantType => cuisine?.type == 'restaurant' || cuisine?.type == 'resturent';
  
  String get entityName => isStoreType ? 'Stores' : 'Restaurants';
  String get entityNameSingular => isStoreType ? 'Store' : 'Restaurant';
  
  String get noDataMessage => isStoreType 
      ? 'No stores found for this category'
      : 'No restaurants found for this cuisine';
  
  String get browseMessage => isStoreType 
      ? 'Browse stores in this category'
      : 'Browse restaurants in this cuisine';
  
  IconData get entityIcon => isStoreType 
      ? Icons.store_outlined 
      : Icons.restaurant_outlined;

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