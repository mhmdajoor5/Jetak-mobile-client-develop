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
        key: _con.scaffoldKey,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back),
            color: Theme.of(context).hintColor,
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: Text(
            S.of(context).cart,
            style: Theme.of(context).textTheme.headlineSmall?.merge(TextStyle(letterSpacing: 1.3)),
          ),
        ),
        body: Container(
          color: Color(0xFFF8F8F8),
          child: RefreshIndicator(
            onRefresh: _con.refreshCarts,
            child: _con.carts.isEmpty
                ? Center(child: Text('Cart is empty'))
                : ListView.separated(
              padding: EdgeInsets.only(top: 10, bottom: 120, left: 16, right: 16),
              itemCount: _con.carts.length,
              separatorBuilder: (context, index) => Column(
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
                return Row(
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
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Color(0xFF223263)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4),
                          Text(
                            cart.food?.description?.replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), '') ?? '',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Color(0xFF9098B1), fontWeight: FontWeight.w400, fontSize: 13),
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
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Color(0xFF223263), fontWeight: FontWeight.bold, fontSize: 16),
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
                  ],
                );
              },
            ),
          ),
        ),
        bottomNavigationBar: _con.carts.isEmpty
            ? SizedBox.shrink()
            : Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
          child: Container(
            height: 56,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Color(0xFF223263),
              borderRadius: BorderRadius.circular(32),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: 44,
                  padding: EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Color(0xFF223263), width: 2),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.shopping_cart, color: Color(0xFF223263), size: 22),
                      SizedBox(width: 4),
                      Text(
                        '${_con.carts.length} Cart',
                        style: TextStyle(
                          color: Color(0xFF223263),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 12),
                // swipeButtonWidget(context: context,),
                // SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _con.isLoading ? null : () => _con.goCheckout(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    elevation: 0,
                    padding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
                  ),
                  child: Text(
                    'Pay now',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                Spacer(),
                Container(
                  height: 44,
                  alignment: Alignment.center,
                  padding: EdgeInsets.only(right: 8),
                  child: Helper.getPrice(
                    _con.total,
                    context,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}