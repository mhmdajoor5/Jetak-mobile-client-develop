import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../helpers/helper.dart';
import '../models/restaurant.dart';
import '../models/route_argument.dart';
import '../repository/settings_repository.dart';

// ignore: must_be_immutable
class CardWidget extends StatelessWidget {
  final Restaurant restaurant;
  final String heroTag;

  const CardWidget({Key? key, required this.restaurant, required this.heroTag})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: 292,
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.all(Radius.circular(10)),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).focusColor.withOpacity(0.1),
              blurRadius: 15,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Stack(
              fit: StackFit.loose,
              alignment: AlignmentDirectional.bottomStart,
              children: <Widget>[
                Hero(
                  tag: this.heroTag + restaurant.id,
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
                    child: CachedNetworkImage(
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      imageUrl: restaurant.image.url,
                      placeholder:
                          (context, url) => Image.asset(
                            'assets/img/loading.gif',
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: 150,
                          ),
                      errorWidget: (context, url, error) => Image.asset('assets/img/logo.png', fit: BoxFit.fill, ),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Color(0xFFEDEFF1),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          'assets/img/ticket-discount.svg',
                          height: 18,
                          width: 18,
                        ),
                        SizedBox(width: 4),
                        Text(
                          ' 20% off (up to \$50)',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Nunito',
                            color: Color(0xFF26386A),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          restaurant.name,
                          overflow: TextOverflow.fade,
                          softWrap: false,
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Color(0xFF272727),
                            height: 1.3,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          Helper.skipHtml(restaurant.description),
                          overflow: TextOverflow.fade,
                          softWrap: false,
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                            color: Color(0xFF9D9FA4),
                            height: 1.3,
                          ),
                        ),

                        Visibility(
                          visible: false,
                          child: Row(
                            children: Helper.getStarsList(
                              double.parse(restaurant.rate),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // SizedBox(width: 15),
                  Visibility(
                    visible: false,
                    child: Expanded(
                      child: Column(
                        children: <Widget>[
                          MaterialButton(
                            padding: EdgeInsets.all(0),
                            onPressed: () {
                              Navigator.of(context).pushNamed(
                                '/Pages',
                                arguments: RouteArgument(
                                  id: '1',
                                  param: restaurant,
                                ),
                              );
                            },
                            child: Icon(
                              Icons.directions,
                              color: Theme.of(context).primaryColor,
                            ),
                            color: Theme.of(context).colorScheme.secondary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          restaurant.distance > 0
                              ? Text(
                                Helper.getDistance(
                                  restaurant.distance,
                                  Helper.of(
                                    context,
                                  ).trans(setting.value.distanceUnit),
                                ),
                                overflow: TextOverflow.fade,
                                maxLines: 1,
                                softWrap: false,
                              )
                              : SizedBox(height: 0),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            /// add here divider
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Divider(
                height: 20,
                thickness: 1.5,
                color: Color(0xFFEDEFF1), // or use Theme.of(context).dividerColor
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.orange, size: 16),
                      SizedBox(width: 4),
                      Text(
                        restaurant.rate.toString(),
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          height: 1.6,
                          color: Color(0xFF9D9FA4),
                        ),
                      ),
                      SizedBox(width: 10),
                      Icon(Icons.access_time, size: 16),
                      SizedBox(width: 4),
                      Text(
                        "20-30 min",
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          height: 1.6,
                          color: Color(0xFF9D9FA4),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
