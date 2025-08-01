import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../models/cart.dart';
import '../models/category.dart';
import '../models/food.dart';
import '../repository/cart_repository.dart';
import '../repository/category_repository.dart';
import '../repository/food_repository.dart';

class CategoryController extends ControllerMVC {
  List<Food> foods = <Food>[];
  late GlobalKey<ScaffoldState> scaffoldKey;
  Category? category;
  bool loadCart = false;
  List<Cart> carts = [];

  CategoryController() {
    scaffoldKey = GlobalKey<ScaffoldState>();
  }

  void listenForFoodsByCategory({String? id, String? message}) async {
    final Stream<Food> stream = await getFoodsByCategory(id);
    stream.listen(
      (Food _food) {
        setState(() => foods.add(_food));
      },
      onError: (_) {
        ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(SnackBar(content: Text(S.of(state!.context).verify_your_internet_connection)));
      },
      onDone: () {
        if (message != null) {
          ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(SnackBar(content: Text(message)));
        }
      },
    );
  }

  void listenForCategory({required String id, String? message}) async {
    final Stream<Category> stream = await getCategory(id);
    stream.listen(
      (Category _category) {
        setState(() => category = _category);
      },
      onError: (_) {
        ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(SnackBar(content: Text(S.of(state!.context).verify_your_internet_connection)));
      },
      onDone: () {
        if (message != null) {
          ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(SnackBar(content: Text(message)));
        }
      },
    );
  }

  Future<void> listenForCart() async {
    final Stream<Cart> stream = await getCart();
    stream.listen((Cart _cart) {
      carts.add(_cart);
    });
  }

  bool isSameRestaurants(Food food) {
    return carts.isEmpty || carts[0].food?.restaurant.id == food.restaurant.id;
  }

  Future<void> addToCart(Food food, BuildContext context, {bool reset = false}) async {
    // Check if cart is not empty and the new food is from a different restaurant
    if (carts.isNotEmpty && !isSameRestaurants(food)) {
      // Show confirmation dialog
      final bool? confirm = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: Text(
            S.of(context).warning,
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            S.of(context).cannot_add_from_different_restaurant,
            style: TextStyle(
              color: Colors.black87,
              fontSize: 16,
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                S.of(context).cancel,
                style: TextStyle(
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                S.of(context).continueText,
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );

      // If user cancels, return without adding to cart
      if (confirm != true) {
        return;
      }
      // If user confirms, reset the cart by setting reset to true
      reset = true;
    }

    setState(() => loadCart = true);

    final Cart newCart = Cart(food: food, extras: food.extras.where((e) => e.checked).toList(), quantity: 1);
    final Cart? oldCart = isExistInCart(newCart);

    if (oldCart != null) {
      oldCart.quantity += 1;
      await updateCart(oldCart);
      await listenForCart();
      setState(() => loadCart = false);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(S.of(context).this_food_was_added_to_cart)));
      }
    } else {
      await addCart(newCart, reset);
      await listenForCart();
      setState(() => loadCart = false);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(S.of(context).this_food_was_added_to_cart)));
      }
    }
  }

  Cart? isExistInCart(Cart cart) {
    return carts.firstWhereOrNull((oldCart) => cart.isSame(oldCart));
  }

  Future<void> refreshCategory(String id) async {
    foods.clear();
    category = Category();
    listenForFoodsByCategory(id: id, message: S.of(state!.context).category_refreshed_successfuly);
    listenForCategory(id: id, message: S.of(state!.context).category_refreshed_successfuly);
  }
}
