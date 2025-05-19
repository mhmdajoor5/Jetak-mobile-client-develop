import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../generated/l10n.dart';
import '../helpers/helper.dart';
import '../models/food.dart';
import '../models/route_argument.dart';

class FoodItemWidget extends StatelessWidget {
  final String heroTag;
  final Food food;

  const FoodItemWidget({Key? key, required this.food, required this.heroTag}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Theme.of(context).colorScheme.secondary,
      focusColor: Theme.of(context).colorScheme.secondary,
      highlightColor: Theme.of(context).primaryColor,
      onTap: () {
        Navigator.of(context).pushNamed('/Food', arguments: RouteArgument(id: food.id, heroTag: heroTag));
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
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(5)),
                child: CachedNetworkImage(
                  height: 60,
                  width: 60,
                  fit: BoxFit.cover,
                  imageUrl: food.image?.thumb ?? '',
                  placeholder: (context, url) => Image.asset('assets/img/loading.gif', fit: BoxFit.cover, height: 60, width: 60),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
              ),
            ),
            SizedBox(width: 15),
            Flexible(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(food.name, overflow: TextOverflow.ellipsis, maxLines: 2, style: Theme.of(context).textTheme.titleMedium),
                          Row(children: Helper.getStarsList(food.getRate())),
                          SizedBox(height: 8),
                          Text("${S.of(context).estimatedTime} ${food.estTime}", style: Theme.of(context).textTheme.bodyLarge),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Helper.getPrice(food.price, context, style: Theme.of(context).textTheme.headlineLarge),
                      food.discountPrice > 0
                          ? Helper.getPrice(food.discountPrice, context, style: Theme.of(context).textTheme.bodyMedium?.merge(TextStyle(decoration: TextDecoration.lineThrough)))
                          : SizedBox.shrink(),
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
