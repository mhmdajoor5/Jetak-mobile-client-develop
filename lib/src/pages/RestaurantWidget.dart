import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import '../controllers/restaurant_controller.dart';
import '../elements/CircularLoadingWidget.dart';
import '../models/cart.dart';
import '../models/food.dart';
import '../models/restaurant.dart';
import '../models/route_argument.dart';
import 'RestaurantAppBar.dart';
import 'restaurant_details_section.dart';
import 'restaurant_bottom_cart.dart';

class RestaurantWidget extends StatefulWidget {
  final RouteArgument? routeArgument;
  final GlobalKey<ScaffoldState>? parentScaffoldKey;

  RestaurantWidget({Key? key, this.parentScaffoldKey, this.routeArgument}) : super(key: key);

  @override
  _RestaurantWidgetState createState() => _RestaurantWidgetState();
}

class _RestaurantWidgetState extends StateMVC<RestaurantWidget> {
  late RestaurantController _con;

  _RestaurantWidgetState() : super(RestaurantController()) {
    _con = controller as RestaurantController;
  }

  final List<Cart> _cart = [];

  int get cartCount => _cart.fold(0, (sum, c) => (sum + (c.quantity ?? 1)).toInt());
  double get totalPrice => _cart.fold(0.0, (sum, c) => sum + (c.food?.price ?? 0) * (c.quantity ?? 1));

  void _addToCart(Food food) {
    setState(() {
      final idx = _cart.indexWhere((c) => c.food?.id == food.id);
      if (idx >= 0) {
        _cart[idx].quantity = (_cart[idx].quantity ?? 1) + 1;
      } else {
        _cart.add(Cart(food: food, quantity: 1));
      }
    });
  }

  @override
  void initState() {
    _con.restaurant = widget.routeArgument?.param as Restaurant;
    _con.listenForFeaturedFoods(_con.restaurant!.id!);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      key: _con.scaffoldKey,
      body: RefreshIndicator(
        onRefresh: _con.refreshRestaurant,
        child: _con.restaurant == null
            ? CircularLoadingWidget(height: 500)
            : Stack(
          fit: StackFit.expand,
          children: <Widget>[
            CustomScrollView(
              slivers: <Widget>[
                RestaurantAppBar(restaurant: _con.restaurant!, routeArgument: widget.routeArgument),
                SliverToBoxAdapter(
                  child: RestaurantDetailsSection(
                    con: _con,
                    cart: _cart,
                    addToCart: _addToCart,
                  ),
                ),
              ],
            ),
            RestaurantBottomCart(
              cartCount: cartCount,
              totalPrice: totalPrice,
            )
          ],
        ),
      ),
    );
  }
}
