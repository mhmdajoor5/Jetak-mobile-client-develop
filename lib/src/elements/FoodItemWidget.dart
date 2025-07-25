import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../controllers/food_controller.dart';
import '../helpers/helper.dart';
import '../models/food.dart';
import '../models/route_argument.dart';

class FoodItemWidget extends StatefulWidget {
  final String heroTag;
  final Food food;
  final VoidCallback onAdd;
  //final Function(Food) onAdd;

  const FoodItemWidget({Key? key, required this.food, required this.heroTag,
   required this.onAdd,
  }) : super(key: key);

  @override
  State<FoodItemWidget> createState() => _FoodItemWidgetState();
}

class _FoodItemWidgetState extends State<FoodItemWidget> {
  void _handleAdd() {
    FoodController().addToCart(widget.food,context);
    widget.onAdd();
  }
  // int cartCount = 0;
  // double totalPrice = 0.0;
  // List<Food> cartItems = [];
  //
  // void _addToCart() {
  //   setState(() {
  //     cartCount++;
  //     totalPrice += widget.food.price;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Theme
          .of(context)
          .colorScheme
          .secondary,
      onTap: () {
        Navigator.of(context).pushNamed(
          '/Food',
          arguments: RouteArgument(id: widget.food.id, heroTag: widget.heroTag),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: Theme
              .of(context)
              .primaryColor
              .withOpacity(0.9),
          boxShadow: [
            BoxShadow(
              color: Theme
                  .of(context)
                  .focusColor
                  .withOpacity(0.05),
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: (widget.food.image?.thumb != null && widget.food.image!.thumb!.isNotEmpty)
                  ? CachedNetworkImage(
                height: 80,
                width: 80,
                fit: BoxFit.cover,
                imageUrl: widget.food.image!.thumb!,
                placeholder: (context, url) => Image.asset(
                  'assets/img/loading.gif',
                  height: 80,
                  width: 80,
                  fit: BoxFit.cover,
                ),
                errorWidget: (context, url, error) {
                  print("Error loading image: $url - $error");
                  return Image.asset(
                    'assets/img/logo.png',
                    fit: BoxFit.fill,
                    height: 80,
                    width: 80,
                  );
                },
              )
                  : Container(
                height: 80,
                width: 80,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 22,
                    child: Text(
                      widget.food.name,
                      style: Theme
                          .of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  SizedBox(height: 4),
                  // Text(
                  //   food.description ?? '',
                  //   maxLines: 2,
                  //   overflow: TextOverflow.ellipsis,
                  //   style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  //     fontSize: 13,
                  //     color: Colors.grey[700],
                  //   ),
                  // ),
                  SizedBox(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 33,
                        height: 22,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Helper.getPrice(
                            widget.food.price,
                            context,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF26386A),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: GestureDetector(
                          // onTap: () {
                          //   setState(() {
                          //     cartCount++;
                          //     totalPrice += widget.food.price;
                          //     cartItems.add(widget.food);
                          //   });
                          //   FoodController().addToCart(widget.food);
                          //   _addToCart();
                          // },
                          onTap: _handleAdd,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Color(0xFF26386A),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Icon(
                                Icons.add,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}