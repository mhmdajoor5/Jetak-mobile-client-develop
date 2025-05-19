import 'dart:async';

import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../models/category.dart';
import '../models/food.dart';
import '../models/gallery.dart';
import '../models/restaurant.dart';
import '../models/review.dart';
import '../repository/category_repository.dart';
import '../repository/food_repository.dart';
import '../repository/gallery_repository.dart';
import '../repository/restaurant_repository.dart';
import '../repository/settings_repository.dart';

class RestaurantController extends ControllerMVC {
   Restaurant? restaurant;
  List<Gallery> galleries = <Gallery>[];
  List<Food> foods = <Food>[];
  List<Category> categories = <Category>[];
  List<Food> trendingFoods = <Food>[];
  List<Food> featuredFoods = <Food>[];
  List<Review> reviews = <Review>[];
  late GlobalKey<ScaffoldState> scaffoldKey;

  final PagingController<int, Food> foodPagingController =
      PagingController(firstPageKey: 1);
  final PagingController<int, Food> featuredFoodsPagingController =
      PagingController(firstPageKey: 1);

  RestaurantController() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
  }

  Future<dynamic> listenForRestaurant({required String id, String? message}) async {
    final whenDone = new Completer();
    final Stream<Restaurant> stream = await getRestaurant(id, deliveryAddress.value);
    stream.listen((Restaurant _restaurant) {
      setState(() => restaurant = _restaurant);
      return whenDone.complete(_restaurant);
    }, onError: (a) {
      print(a);
      ScaffoldMessenger.of(scaffoldKey.currentState!.context).showSnackBar(SnackBar(
        content: Text(S.of(state!.context).verify_your_internet_connection),
      ));
      return whenDone.complete(Restaurant.fromJSON({}));
    }, onDone: () {
      if (message != null) {
        ScaffoldMessenger.of(scaffoldKey.currentState!.context).showSnackBar(SnackBar(
          content: Text(message),
        ));
        return whenDone.complete(restaurant);
      }
    });
    return whenDone.future;
  }

  void listenForGalleries(String idRestaurant) async {
    final Stream<Gallery> stream = await getGalleries(idRestaurant);
    stream.listen((Gallery _gallery) {
      setState(() => galleries.add(_gallery));
    }, onError: (a) {}, onDone: () {});
  }

  void listenForRestaurantReviews({required String id, String? message}) async {
    final Stream<Review> stream = await getRestaurantReviews(id);
    stream.listen((Review _review) {
      setState(() => reviews.add(_review));
    }, onError: (a) {}, onDone: () {});
  }

  Future<void> listenForFoods(String idRestaurant, int pageKey,
      {List<String> categoriesId = const []}) async {
    try {
      // Fetch a page of foods
      final Stream<Food> stream = await getFoodsOfRestaurant(
        idRestaurant,
        page: pageKey,
        categories: categoriesId,
      );
      List<Food> newFoods = [];

      await for (var food in stream) {
        newFoods.add(food);
      }

      if (pageKey == 1 && newFoods.isNotEmpty) {
        restaurant?.name = newFoods.first.restaurant.name;
      }

      final isLastPage = newFoods.length < 5;
      if (isLastPage) {
        foodPagingController.appendLastPage(newFoods);
      } else {
        final nextPageKey = pageKey + 1;
        foodPagingController.appendPage(newFoods, nextPageKey);
      }
    } catch (error) {
      foodPagingController.error = error;
    }
  }

  void listenForTrendingFoods(String idRestaurant) async {
    final Stream<Food> stream = await getTrendingFoodsOfRestaurant(idRestaurant);
    stream.listen((Food _food) {
      setState(() => trendingFoods.add(_food));
    }, onError: (a) {
      print(a);
    }, onDone: () {});
  }

  void listenForFeaturedFoods(String idRestaurant) async {
    final Stream<Food> stream = await getFeaturedFoodsOfRestaurant(idRestaurant);
    stream.listen((Food _food) {
      setState(() => featuredFoods.add(_food));
    }, onError: (a) {
      print(a);
    }, onDone: () {});
  }

  Future<void> listenForCategories(String restaurantId) async {
    final Stream<Category> stream = await getCategoriesOfRestaurant(restaurantId);
    stream.listen((Category _category) {
      setState(() => categories.add(_category));
    }, onError: (a) {
      print(a);
    }, onDone: () {
      categories.insert(0, new Category.fromJSON({'id': '0', 'name': S.of(state!.context).all}));
    });
  }

  Future<void> selectCategory(List<String> categoriesId) async {
    foodPagingController.value.itemList?.clear();
    listenForFoods(restaurant!.id, 0, categoriesId: categoriesId);
    foodPagingController.refresh() ;
  }

  Future<void> refreshRestaurant() async {
    var _id = restaurant!.id;
    restaurant = new Restaurant();
    galleries.clear();
    reviews.clear();
    featuredFoods.clear();
    listenForRestaurant(id: _id, message: S.of(state!.context).restaurant_refreshed_successfuly);
    listenForRestaurantReviews(id: _id);
    listenForGalleries(_id);
    listenForFeaturedFoods(_id);
  }
}
