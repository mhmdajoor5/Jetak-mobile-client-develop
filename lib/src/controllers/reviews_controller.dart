import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../models/food.dart';
import '../models/order.dart';
import '../models/order_status.dart';
import '../models/review.dart';
import '../repository/food_repository.dart' as foodRepo;
import '../repository/order_repository.dart';
import '../repository/restaurant_repository.dart' as restaurantRepo;

class ReviewsController extends ControllerMVC {
  late Review restaurantReview;
  List<Review> foodsReviews = [];
  late Order order;
  List<Food> foodsOfOrder = [];
  List<OrderStatus> orderStatus = <OrderStatus>[];
  late GlobalKey<ScaffoldState> scaffoldKey;

  ReviewsController() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
    this.restaurantReview = new Review.init("0");
  }

  void listenForOrder({required String orderId, String? message}) async {
    final Stream<Order> stream = await getOrder(orderId);
    stream.listen(
      (Order _order) {
        setState(() {
          order = _order;
          foodsReviews = List.generate(order.foodOrders.length, (_) => new Review.init("0"));
        });
      },
      onError: (a) {
        print(a);
        ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(SnackBar(content: Text(S.of(state!.context).verify_your_internet_connection)));
      },
      onDone: () {
        getFoodsOfOrder();
        if (message != null) {
          ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(SnackBar(content: Text(message)));
        }
      },
    );
  }

  void addFoodReview(Review _review, Food _food) async {
    foodRepo.addFoodReview(_review, _food).then((value) {
      ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(SnackBar(content: Text(S.of(state!.context).the_food_has_been_rated_successfully)));
    });
  }

  void addRestaurantReview(Review _review) async {
    restaurantRepo.addRestaurantReview(_review, this.order.foodOrders[0].food!.restaurant).then((value) {
      refreshOrder();
      ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(SnackBar(content: Text(S.of(state!.context).the_restaurant_has_been_rated_successfully)));
    });
  }

  Future<void> refreshOrder() async {
    listenForOrder(orderId: order.id, message: S.of(state!.context).reviews_refreshed_successfully);
  }

  void getFoodsOfOrder() {
    this.order.foodOrders.forEach((_foodOrder) {
      if (!foodsOfOrder.contains(_foodOrder.food)) {
        foodsOfOrder.add(_foodOrder.food!);
      }
    });
  }
}
