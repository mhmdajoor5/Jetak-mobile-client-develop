import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../models/cart.dart';
import '../models/favorite.dart';
import '../models/food.dart';
import '../repository/cart_repository.dart';
import '../repository/food_repository.dart';

class FoodController extends ControllerMVC {
  late Food food;
  double quantity = 1;
  double total = 0;
  List<Cart> carts = [];
  Favorite favorite = Favorite();
  bool loadCart = false;
  List<String> selectedExtras = [];
  late GlobalKey<ScaffoldState> scaffoldKey;

  FoodController() {
    scaffoldKey = GlobalKey<ScaffoldState>();
    food = Food();
  }

  void listenForFood(BuildContext context, {required String foodId, String? message}) async {
    final Stream<Food> stream = await getFood(foodId);
    stream.listen(
          (Food _food) {
        setState(() => food = _food);
      },
      onError: (e) {
        print(e);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(S.of(state!.context).verify_your_internet_connection), duration: Duration(milliseconds: 300)));
      },
      onDone: () {
        calculateTotal();
        if (message != null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), duration: Duration(milliseconds: 300)));
        }
      },
    );
  }

  void listenForFavorite({required String foodId}) async {
    final Stream<Favorite> stream = await isFavoriteFood(foodId);
    stream.listen((Favorite _favorite) {
      setState(() => favorite = _favorite);
    }, onError: print);
  }

  void listenForCart() async {
    final Stream<Cart> stream = await getCart();
    stream.listen((Cart _cart) {
      carts.add(_cart);
    });
  }

  bool isSameRestaurants(Food food) {
    return carts.isEmpty || carts[0].food?.restaurant.id == food.restaurant.id;
  }

  void addToCart(Food food,  BuildContext context ,{bool reset = false} ) async {
    setState(() => loadCart = true);

    final Cart newCart = Cart(food: food, extras: food.extras.where((e) => e.checked).toList(), quantity: quantity);
    // final Cart newCart = Cart()
    //   ..food = food
    //   ..extras = food.extras.where((e) => e.checked).toList()
    //   ..quantity = quantity;

    final Cart? oldCart = isExistInCart(newCart);

    if (oldCart != null) {
      oldCart.quantity += quantity;
      await updateCart(oldCart);
      setState(() => loadCart = false);
      ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(SnackBar(content: Text(S.of(state!.context).this_food_was_added_to_cart)));
    } else {
      await addCart(newCart, reset);
      setState(() => loadCart = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(S.of(context).this_food_was_added_to_cart)));
      // Navigator.pop(context);
    }
  }

  Cart? isExistInCart(Cart cart) {
    return carts.firstWhereOrNull((oldCart) => cart.isSame(oldCart));
  }

  void addToFavorite(Food food) async {
    final fav =
    Favorite()
      ..food = food
      ..extras = food.extras.where((e) => e.checked).toList();

    addFavorite(fav).then((value) {
      setState(() => favorite = value);
      ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(SnackBar(content: Text(S.of(state!.context).thisFoodWasAddedToFavorite)));
    });
  }

  void removeFromFavorite(Favorite fav) async {
    removeFavorite(fav).then((_) {
      setState(() => favorite = Favorite());
      ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(SnackBar(content: Text(S.of(state!.context).thisFoodWasRemovedFromFavorites)));
    });
  }

  Future<void> refreshFood(BuildContext context) async {
    final id = food.id;
    food = Food();
    listenForFavorite(foodId: id);
    listenForFood(context, foodId: id, message: S.of(state!.context).foodRefreshedSuccessfuly);
  }

  void calculateTotal() {
    total = (food.price ?? 0) + food.extras.where((e) => e.checked).fold(0.0, (sum, e) => sum + e.price);
    total *= quantity;
    setState(() {});
  }

  void incrementQuantity() {
    if (quantity < 100) {
      quantity++;
      calculateTotal();
    }
  }

  void decrementQuantity() {
    if (quantity > 1) {
      quantity--;
      calculateTotal();
    }
  }
}
