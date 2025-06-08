import 'dart:async';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../helpers/helper.dart';
import '../models/category.dart';
import '../models/food.dart';
import '../models/gallery.dart';
import '../models/restaurant.dart';
import '../models/resturant/most_order_model.dart';
import '../models/review.dart';
import '../repository/category_repository.dart';
import '../repository/food_repository.dart';
import '../repository/gallery_repository.dart';
import '../repository/restaurant_repository.dart';
import '../repository/resturant/get_most_order_repo.dart';
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

  final PagingController<int, Food> foodPagingController = PagingController(firstPageKey: 1);
  final PagingController<int, Food> featuredFoodsPagingController = PagingController(firstPageKey: 1);

  Map<String, Future<List<Food>>> foodsByCategory = {};
  List<MostOrderModel> popularFoodForRest = <MostOrderModel>[];
  bool getMostOrderDone = false;

  RestaurantController() {
    this.scaffoldKey = GlobalKey<ScaffoldState>();
  }


  Future<void> listenForMostOrderRest({required restId}) async {
    setState(() {
      getMostOrderDone = false;
      popularFoodForRest = [];
    });
    try {
      final result = await getMostOrder(restID: restId);
      setState(() {
        popularFoodForRest = result;
        getMostOrderDone = true;
      });
    } catch (error) {
      setState(() {
        getMostOrderDone = true;
      });
    }
  }

  Future<Restaurant> listenForRestaurant({
    required String id,
    String? message,
  }) async {
    final whenDone = Completer<Restaurant>();
    final Stream<Restaurant> stream = await getRestaurant(id, deliveryAddress.value);
    stream.listen(
          (Restaurant _restaurant) {
        final double userLat = deliveryAddress.value.latitude?.toDouble() ?? 0.0;
        final double userLng = deliveryAddress.value.longitude?.toDouble() ?? 0.0;
        final double restLat = double.tryParse(_restaurant.latitude) ?? 0.0;
        final double restLng = double.tryParse(_restaurant.longitude) ?? 0.0;
        final double dist = Helper.calculateDistance(userLat, userLng, restLat, restLng);

        _restaurant.availableForDelivery = dist <= (_restaurant.deliveryRange?.toDouble() ?? 0.0);

        setState(() {
          restaurant = _restaurant;
        });
        whenDone.complete(_restaurant);
      },
      onError: (error) {
        ScaffoldMessenger.of(scaffoldKey.currentState!.context).showSnackBar(
          SnackBar(content: Text(S.of(state!.context).verify_your_internet_connection)),
        );
        whenDone.complete(Restaurant.fromJSON({}));
      },
      onDone: () {
        if (message != null) {
          ScaffoldMessenger.of(scaffoldKey.currentState!.context)
              .showSnackBar(SnackBar(content: Text(message)));
        }
      },
    );
    return whenDone.future;
  }

  Future<List<Food>> getFoodsByCategoryId(String categoryId) async {
    if (foodsByCategory.containsKey(categoryId)) {
      return foodsByCategory[categoryId]!;
    }
    final completer = Completer<List<Food>>();
    foodsByCategory[categoryId] = completer.future;
    try {
      final stream = await getFoodsOfRestaurant(restaurant!.id, categories: [categoryId], page: 1);
      final List<Food> categoryFoods = [];
      await for (var food in stream) {
        categoryFoods.add(food);
      }
      completer.complete(categoryFoods);
      return categoryFoods;
    } catch (e) {
      completer.completeError(e);
      return [];
    }
  }

  Future<void> listenForFoods(String idRestaurant, int pageKey, {List<String> categoriesId = const []}) async {
    try {
      final stream = await getFoodsOfRestaurant(idRestaurant, page: pageKey, categories: categoriesId);
      final List<Food> newFoods = [];
      await for (var food in stream) {
        newFoods.add(food);
      }
      final isLastPage = newFoods.length < 5;
      if (isLastPage) {
        foodPagingController.appendLastPage(newFoods);
      } else {
        foodPagingController.appendPage(newFoods, pageKey + 1);
      }
    } catch (error) {
      foodPagingController.error = error;
    }
  }

  void listenForTrendingFoods(String idRestaurant) async {
    final stream = await getTrendingFoodsOfRestaurant(idRestaurant);
    stream.listen(
          (food) => setState(() => trendingFoods.add(food)),
      onError: (_) {},
    );
  }

  void listenForFeaturedFoods(String idRestaurant) async {
    final stream = await getFeaturedFoodsOfRestaurant(idRestaurant);
    stream.listen(
          (food) => setState(() => featuredFoods.add(food)),
      onError: (_) {},
    );
  }

  bool getCategoriesDone = false;
  Map<String, List<Food>> categoryFoods = {};
  bool getAllFoodsDone = false;

  Future<void> listenForCategories(String restaurantId) async {
    setState(() {
      getCategoriesDone = false;
      getAllFoodsDone = false;
      categories = [];
      categoryFoods.clear();
    });
    final fetchedCategories = await getCategoriesOfRestaurant(restaurantId);
    final filtered = fetchedCategories.where((c) => c.id != '0').toList();
    setState(() {
      categories = filtered;
      getCategoriesDone = true;
    });
    for (var c in filtered) {
      final foods = await getFoodsByCategoryId(c.id!);
      categoryFoods[c.id!] = foods;
    }
    setState(() {
      getAllFoodsDone = true;
    });
  }

  Future<void> refreshRestaurant() async {
    final _id = restaurant!.id;
    restaurant = Restaurant();
    galleries.clear();
    reviews.clear();
    featuredFoods.clear();
    foodsByCategory.clear();
    await listenForRestaurant(id: _id, message: S.of(state!.context).restaurant_refreshed_successfuly);
    listenForFeaturedFoods(_id);
    listenForCategories(_id);
  }
}
