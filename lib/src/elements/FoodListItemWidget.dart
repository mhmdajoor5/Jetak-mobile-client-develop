import 'package:flutter/material.dart';

import '../helpers/helper.dart';
import '../models/food.dart';
import '../models/route_argument.dart';

// ignore: must_be_immutable
class FoodListItemWidget extends StatelessWidget {
  final String heroTag;
  final Food food;

  FoodListItemWidget({Key? key, required this.heroTag, required this.food}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Theme.of(context).colorScheme.secondary,
      focusColor: Theme.of(context).colorScheme.secondary,
      highlightColor: Theme.of(context).primaryColor,
      onTap: () {
        Navigator.of(context).pushNamed('/Food', arguments: RouteArgument(heroTag: heroTag, id: food.id));
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.9),
          boxShadow: [BoxShadow(color: Theme.of(context).focusColor.withOpacity(0.1), blurRadius: 5, offset: Offset(0, 2))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Hero(
              tag: heroTag + food.id,
              child: Container(
                height: 60,
                width: 60,
                decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(5)), image: DecorationImage(image: NetworkImage(food.image?.thumb ?? ''), fit: BoxFit.cover)),
              ),
            ),
            SizedBox(width: 15),
            Flexible(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(food.name, overflow: TextOverflow.ellipsis, maxLines: 2, style: Theme.of(context).textTheme.titleMedium),
                        Text(food.restaurant.name, overflow: TextOverflow.fade, softWrap: false, style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ),
                  SizedBox(width: 8),
                  Helper.getPrice(food.price, context, style: Theme.of(context).textTheme.headlineLarge),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
