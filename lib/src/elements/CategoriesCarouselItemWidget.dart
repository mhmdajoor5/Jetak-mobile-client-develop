import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../models/category.dart';
import '../models/route_argument.dart';

class CategoriesCarouselItemWidget extends StatelessWidget {
  final double marginLeft;
  final Category category;

  CategoriesCarouselItemWidget({Key? key, required this.marginLeft, required this.category}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;

    if ((category.image?.url ?? '').toLowerCase().endsWith('.svg')) {
      imageWidget = SvgPicture.network(
        category.image!.url,
        fit: BoxFit.cover,
        color: Theme.of(context).colorScheme.secondary,
      );
    } else if (category.image?.icon != null &&
        category.image!.icon.isNotEmpty &&
        category.image!.icon.startsWith('http')) {
      imageWidget = CachedNetworkImage(
        fit: BoxFit.cover,
        imageUrl: category.image!.icon,
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
        Navigator.of(context).pushNamed('/Category', arguments: RouteArgument(id: category.id));
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Hero(
            tag: category.id!,
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
                child: (category.image?.url ?? '').toLowerCase().endsWith('.svg')
                    ? Image.asset(
                  'assets/img/restaurant.png',
                  fit: BoxFit.cover,
                )
                    : (category.image?.icon != null &&
                    category.image!.icon.isNotEmpty &&
                    category.image!.icon.startsWith('http'))
                    ? CachedNetworkImage(
                  fit: BoxFit.cover,
                  imageUrl: category.image!.icon,
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
          Container(margin: EdgeInsetsDirectional.only(start: this.marginLeft, end: 20), child: Text(category.name!, overflow: TextOverflow.ellipsis,
            style: TextStyle(
              //fontFamily: 'Nunito',
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
