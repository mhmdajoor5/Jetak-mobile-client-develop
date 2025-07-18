import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../helpers/helper.dart';
import '../models/restaurant.dart';
import '../models/route_argument.dart';

class GridItemWidget extends StatelessWidget {
  final Restaurant restaurant;
  final String heroTag;

  GridItemWidget({Key? key, required this.restaurant, required this.heroTag}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      highlightColor: Colors.transparent,
      splashColor: Theme.of(context).colorScheme.secondary.withOpacity(0.08),
      onTap: () {
        Navigator.of(context).pushNamed('/Details', arguments: RouteArgument(id: "0", param: restaurant.id, heroTag: heroTag));
      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.all(Radius.circular(5)),
          boxShadow: [BoxShadow(color: Theme.of(context).focusColor.withOpacity(0.05), offset: Offset(0, 5), blurRadius: 5)],
        ),
        child: Wrap(
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.only(topLeft: Radius.circular(5), topRight: Radius.circular(5)),
              child: Hero(
                tag: heroTag + restaurant.id,
                child: CachedNetworkImage(
                  height: 100,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  imageUrl: restaurant.image.url,
                  placeholder: (context, url) => Image.asset('assets/img/loading.gif', fit: BoxFit.cover, width: double.infinity, height: 82),
                  errorWidget: (context, url, error) => Image.asset('assets/img/logo.png', fit: BoxFit.fill, ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(restaurant.name, style: Theme.of(context).textTheme.bodyMedium, softWrap: false, maxLines: 3, overflow: TextOverflow.ellipsis),
                  SizedBox(height: 2),
                  Row(children: Helper.getStarsList(double.parse(restaurant.rate))),
                  SizedBox(height: 2),
                  Row(children: [Text(restaurant.information)]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
