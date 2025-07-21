import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../controllers/cart_controller.dart';
import '../helpers/helper.dart';
import '../helpers/swipe_button_widget.dart';
import '../models/route_argument.dart';
import '../repository/settings_repository.dart';
import '../controllers/food_controller.dart';

class CartWidget extends StatefulWidget {
  final RouteArgument? routeArgument;

  CartWidget({Key? key, this.routeArgument}) : super(key: key);

  @override
  _CartWidgetState createState() => _CartWidgetState();
}

class _CartWidgetState extends StateMVC<CartWidget> {
  late CartController _con;

  _CartWidgetState() : super(CartController()) {
    _con = controller as CartController;
  }

  @override
  void initState() {
    _con.listenForCarts();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: Helper.of(context).onWillPop,
      child: Scaffold(
        // floatingActionButton: IconButton(
        //   onPressed: () async {
        //      _con.removeFromCart(_con.carts[0]);
        //   },
        //   icon: Icon(Icons.delete),
        // ),
        key: _con.scaffoldKey,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: IconButton(
            onPressed: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              } else {
                Navigator.of(context).pushReplacementNamed('/Pages', arguments: 0);
              }
            },
            icon: Icon(Icons.arrow_back),
            color: Theme.of(context).hintColor,
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: Text(
            S.of(context).cart,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.merge(TextStyle(letterSpacing: 1.3)),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: Container(
                color: Color(0xFFF8F8F8),
                child: RefreshIndicator(
                  onRefresh: _con.refreshCarts,
                  child:
                      _con.carts.isEmpty
                          ? Center(child: Text('Cart is empty'))
                          : ListView.separated(
                            padding: EdgeInsets.only(
                              top: 10,
                              bottom: 120,
                              left: 16,
                              right: 16,
                            ),
                            itemCount: _con.carts.length,
                            separatorBuilder:
                                (context, index) => Column(
                                  children: [
                                    SizedBox(height: 10),
                                    Divider(
                                      height: 1,
                                      thickness: 0.7,
                                      color: Color(0xFFE0E0E0),
                                    ),
                                    SizedBox(height: 10),
                                  ],
                                ),
                            itemBuilder: (context, index) {
                              final cart = _con.carts[index];
                              return Dismissible(
                                key: ValueKey(cart.id), // Make sure cart.id is unique
                                direction: DismissDirection.horizontal,
                                onDismissed: (direction) {
                                  _con.removeFromCart(cart);
                                },
                                background: Container(
                                  color: Colors.redAccent,
                                  alignment: Alignment.centerLeft,
                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                  child: Icon(Icons.delete, color: Colors.white),
                                ),
                                secondaryBackground: Container(
                                  color: Colors.redAccent,
                                  alignment: Alignment.centerRight,
                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                  child: Icon(Icons.delete, color: Colors.white),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        cart.food?.image?.thumb ?? '',
                                        width: 70,
                                        height: 70,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => Container(
                                          width: 70,
                                          height: 70,
                                          color: Colors.grey[200],
                                          child: Icon(Icons.image, color: Colors.grey),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            cart.food?.name ?? '',
                                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF223263),
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            cart.food?.description?.replaceAll(
                                              RegExp(r'<[^>]*>|&[^;]+;'),
                                              '',
                                            ) ??
                                                '',
                                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              color: Color(0xFF9098B1),
                                              fontWeight: FontWeight.w400,
                                              fontSize: 13,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          SizedBox(height: 8),
                                          Helper.getPrice(
                                            cart.food?.price ?? 0,
                                            context,
                                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF223263),
                                              fontSize: 18,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Column(
                                      children: [
                                        Row(
                                          children: [
                                            InkWell(
                                              onTap: () => _con.decrementQuantity(cart),
                                              borderRadius: BorderRadius.circular(20),
                                              child: Container(
                                                width: 36,
                                                height: 36,
                                                decoration: BoxDecoration(
                                                  color: Color(0xFFE0E0E0),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Icon(Icons.remove, color: Color(0xFF9098B1), size: 20),
                                              ),
                                            ),
                                            SizedBox(width: 10),
                                            Text(
                                              cart.quantity?.toString() ?? '1',
                                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                color: Color(0xFF223263),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            SizedBox(width: 10),
                                            InkWell(
                                              onTap: () => _con.incrementQuantity(cart),
                                              borderRadius: BorderRadius.circular(20),
                                              child: Container(
                                                width: 36,
                                                height: 36,
                                                decoration: BoxDecoration(
                                                  color: Color(0xFF223263),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Icon(Icons.add, color: Colors.white, size: 20),
                                              ),
                                            ),
                                          ],
                                        ),
                                        // IconButton(
                                        //   onPressed: () => _con.removeFromCart(cart),
                                        //   icon: Icon(Icons.delete),
                                        // ),
                                      ],
                                    ),
                                  ],
                                ),
                              )
                              ;
                            },
                          ),
                ),
              ),
            ),

            // Padding(
            //   padding: const EdgeInsets.all(16.0),
            //   child: SwipeButtonWidget(context: context, numOfItems: _con.carts.length, onSwipe: _con.isLoading ? null : () => _con.goCheckout(context),),
            // ),
          ],
        ),
        bottomNavigationBar:
            _con.carts.isEmpty
                ? SizedBox.shrink()
                : Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12,
                  ),
                  child: SwipeButtonWidget(
                    context: context,
                    numOfItems: _con.carts.length,
                    onSwipe:
                        _con.isLoading ? null : () => _con.goCheckout(context),
                    totalPrice: (() {
                      final subTotal = _con.subTotal;
                      final taxAmount = subTotal * (_con.carts.isNotEmpty ? _con.carts[0].food!.restaurant.defaultTax : 0) / 100;
                      return subTotal + taxAmount;
                    })(),
                  ),
                ),
      ),
    );
  }
}
