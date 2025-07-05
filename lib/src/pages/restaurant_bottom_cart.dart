import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import '../controllers/cart_controller.dart';

class RestaurantBottomCart extends StatefulWidget {
  const RestaurantBottomCart({Key? key}) : super(key: key);

  @override
  _RestaurantBottomCartState createState() => _RestaurantBottomCartState();
}

class _RestaurantBottomCartState extends StateMVC<RestaurantBottomCart> {
  late CartController _con;

  _RestaurantBottomCartState() : super(CartController()) {
    _con = controller as CartController;
  }

  @override
  void initState() {
    super.initState();
    _con.listenForCarts();
    _con.listenForCartsCount();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 8,
      left: 16,
      right: 16,
      child: SizedBox(
        height: 48,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(
            color: const Color(0xFF26386A),
            borderRadius: BorderRadius.circular(30),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              InkWell(
                onTap: () {
                  Navigator.of(context).pushNamed('/Cart');
                },
                child: Container(
                  height: 44,
                  width: 120,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(
                        'assets/img/bag.svg',
                        height: 27,
                        width: 27,
                        color: Colors.black87,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${_con.cartCount} Cart',
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Total',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              Text(
                '\$${_con.total.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 16),
              InkWell(
                onTap: () {
                  if (_con.cartCount > 0) {
                    _con.goCheckout(context);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: _con.cartCount > 0 ? Colors.green : Colors.grey,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Checkout',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}