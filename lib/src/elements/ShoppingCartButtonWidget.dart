import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../controllers/cart_controller.dart';
import '../models/route_argument.dart';
import '../repository/user_repository.dart';

class ShoppingCartButtonWidget extends StatefulWidget {
  final Color? iconColor;
  final Color? labelColor;

  const ShoppingCartButtonWidget({
    Key? key,
    this.iconColor,
    this.labelColor,
  }) : super(key: key);

  @override
  _ShoppingCartButtonWidgetState createState() =>
      _ShoppingCartButtonWidgetState();
}

class _ShoppingCartButtonWidgetState
    extends StateMVC<ShoppingCartButtonWidget> {
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
    return GestureDetector(
      onTap: () {
        if (currentUser.value.apiToken != null) {
          Navigator.of(context).pushNamed(
            '/Cart',
            arguments: RouteArgument(param: '/Pages', id: '2'),
          );
        } else {
          Navigator.of(context).pushNamed('/Login');
        }
      },
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Color(0xFFF9F9F9),
          shape: BoxShape.circle,
          border: Border.all(
            color: Color(0xFFEAEAEA),
            width: 1,
          ),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            SvgPicture.asset(
              'assets/img/bag.svg',
              height: 27,
              width: 27,
            ),
            if (_con.cartCount > 0)
              Positioned(
                top: -6,
                right: -6,
                child: Container(
                  width: 22,
                  height: 22,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: widget.labelColor ?? Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    _con.cartCount.toString(),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
