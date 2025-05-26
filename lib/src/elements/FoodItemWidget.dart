import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../generated/l10n.dart';
import '../helpers/helper.dart';
import '../models/food.dart';
import '../models/route_argument.dart';
import 'CardWidget.dart' show CardWidget;

class FoodItemWidget extends StatelessWidget {
  final String heroTag;
  final Food food;

  const FoodItemWidget({Key? key, required this.food, required this.heroTag}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Theme.of(context).colorScheme.secondary,
      onTap: () {
        Navigator.of(context).pushNamed(
          '/Food',
          arguments: RouteArgument(id: food.id, heroTag: heroTag),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.9),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).focusColor.withOpacity(0.05),
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
              child: CachedNetworkImage(
                height: 80,
                width: 80,
                fit: BoxFit.cover,
                imageUrl: food.image?.thumb ?? '',
                placeholder: (context, url) => Image.asset(
                  'assets/img/loading.gif',
                  height: 80,
                  width: 80,
                  fit: BoxFit.cover,
                ),
                errorWidget: (context, url, error) => Image.asset('assets/img/logo.png', fit: BoxFit.fill, ),
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                SizedBox(
                height: 22,
                  child: Text(
                    food.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
                        food.price,
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
                          onTap: () {
                          },
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
