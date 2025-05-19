import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../controllers/cart_controller.dart';
import '../models/route_argument.dart';
import '../repository/user_repository.dart';

class ShoppingCartButtonWidget extends StatefulWidget {
  final Color iconColor;
  final Color labelColor;

  const ShoppingCartButtonWidget({Key? key, required this.iconColor, required this.labelColor}) : super(key: key);

  @override
  _ShoppingCartButtonWidgetState createState() => _ShoppingCartButtonWidgetState();
}

class _ShoppingCartButtonWidgetState extends StateMVC<ShoppingCartButtonWidget> {
  late CartController _con;

  _ShoppingCartButtonWidgetState() : super(CartController()) {
    _con = controller as CartController;
  }

  @override
  void initState() {
    super.initState();
    _con.listenForCartsCount();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      elevation: 0,
      focusElevation: 0,
      highlightElevation: 0,
      onPressed: () {
        if (currentUser.value.apiToken != null) {
          Navigator.of(context).pushNamed('/Cart', arguments: RouteArgument(param: '/Pages', id: '2'));
        } else {
          Navigator.of(context).pushNamed('/Login');
        }
      },
      color: Colors.transparent,
      child: Stack(
        alignment: AlignmentDirectional.bottomEnd,
        children: <Widget>[
          Icon(Icons.shopping_cart, color: widget.iconColor, size: 28),
          if (_con.cartCount > 0)
            Container(
              padding: EdgeInsets.all(0),
              decoration: BoxDecoration(color: widget.labelColor, borderRadius: BorderRadius.all(Radius.circular(10))),
              constraints: BoxConstraints(minWidth: 15, maxWidth: 15, minHeight: 15, maxHeight: 15),
              child: Text(_con.cartCount.toString(), textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).primaryColor, fontSize: 9)),
            ),
        ],
      ),
    );
  }
}
