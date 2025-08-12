import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../models/cuisine.dart';
import '../models/route_argument.dart';

class CuisinesCarouselItemWidget extends StatelessWidget {
  final double marginLeft;
  final Cuisine cuisine;

  CuisinesCarouselItemWidget({Key? key, required this.marginLeft, required this.cuisine}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;

    if ((cuisine.image.url ?? '').toLowerCase().endsWith('.svg')) {
      imageWidget = SvgPicture.network(
        cuisine.image.url!,
        fit: BoxFit.cover,
        color: Theme.of(context).colorScheme.secondary,
      );
    } else if (cuisine.image.icon != null &&
        cuisine.image.icon!.isNotEmpty &&
        cuisine.image.icon!.startsWith('http')) {
      imageWidget = CachedNetworkImage(
        fit: BoxFit.cover,
        imageUrl: cuisine.image.icon!,
        placeholder: (context, url) => Image.asset(
          'assets/img/restaurant.png',
          fit: BoxFit.cover,
        ),
        errorWidget: (context, url, error) => Image.asset(
          'assets/img/restaurant.png',
          fit: BoxFit.cover,
        ),
      );
    } else {
      imageWidget = Image.asset(
        'assets/img/restaurant.png',
        fit: BoxFit.cover,
      );
    }

    return InkWell(
      splashColor: Theme.of(context).colorScheme.secondary.withOpacity(0.08),
      highlightColor: Colors.transparent,
      onTap: () {
        Navigator.of(context).pushNamed('/Cuisine', arguments: RouteArgument(id: cuisine.id));
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Hero(
            tag: cuisine.id,
            child: Container(
              margin: EdgeInsetsDirectional.only(start: this.marginLeft, end: 20),
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).focusColor.withOpacity(0.2),
                    offset: Offset(0, 2),
                    blurRadius: 7.0,
                  ),
                ],
              ),
              child: ClipOval(
                child: (cuisine.image.url ?? '').toLowerCase().endsWith('.svg')
                    ? Image.asset(
                  'assets/img/restaurant.png',
                  fit: BoxFit.cover,
                )
                    : (cuisine.image.icon != null &&
                    cuisine.image.icon!.isNotEmpty &&
                    cuisine.image.icon!.startsWith('http'))
                    ? CachedNetworkImage(
                  fit: BoxFit.cover,
                  imageUrl: cuisine.image.icon!,
                  placeholder: (context, url) => Image.asset(
                    'assets/img/restaurant.png',
                    fit: BoxFit.cover,
                  ),
                  errorWidget: (context, url, error) => Image.asset(
                    'assets/img/restaurant.png',
                    fit: BoxFit.cover,
                  ),
                )
                    : Image.asset(
                  'assets/img/restaurant.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SizedBox(height: 5),
          Container(
            margin: EdgeInsetsDirectional.only(start: this.marginLeft, end: 20), 
            child: Text(
              cuisine.name, 
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 13,
                height: 1.6,
                color: Color(0xFF9D9FA4),
              ),
            )
          ),
        ],
      ),
    );
  }
} 