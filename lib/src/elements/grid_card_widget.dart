import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../helpers/helper.dart';
import '../models/restaurant.dart';

class GridCardWidget extends StatelessWidget {
  final Restaurant restaurant;

  const GridCardWidget({Key? key, required this.restaurant}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('Rating: ${restaurant.rate}');
    return InkWell(
      onTap: () {
        print("mElkerm");
        // print(restaurant.name);
        // Navigator.of(context).pushNamed('/Details', arguments: restaurant);
        Navigator.of(context).pushNamed('/Details', arguments: restaurant);

      },
      child: Container(
        margin: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(10),
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
          children: [
            Stack(
              alignment: AlignmentDirectional.bottomStart,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                  child: CachedNetworkImage(
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    imageUrl: restaurant.image.url,
                    placeholder: (context, url) => Image.asset(
                      'assets/img/loading.gif',
                      fit: BoxFit.cover,
                      height: 150,
                    ),
                    errorWidget: (context, url, error) => Image.asset(
                      'assets/img/logo.png',
                      fit: BoxFit.cover,
                      height: 150,
                    ),
                  ),
                ),
                // Positioned(
                //   top: 12,
                //   left: 12,
                //   child: Container(
                //     padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                //     decoration: BoxDecoration(
                //       color: Colors.white.withOpacity(0.85),
                //       borderRadius: BorderRadius.circular(20),
                //     ),
                //     child: Row(
                //       mainAxisSize: MainAxisSize.min,
                //       children: [
                //         SvgPicture.asset(
                //           'assets/img/ticket-discount.svg',
                //           height: 16,
                //           width: 16,
                //         ),
                //         SizedBox(width: 5),
                //         Text(
                //           '20% off (up to \$50)',
                //           style: TextStyle(
                //             fontSize: 12,
                //             fontWeight: FontWeight.w500,
                //             //fontFamily: 'Nunito',
                //             color: Color(0xFF26386A),
                //           ),
                //         ),
                //       ],
                //     ),
                //   ),
                // ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    restaurant.name,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(
                      //fontFamily: 'Nunito',
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Color(0xFF272727),
                      height: 1.3,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    Helper.skipHtml(restaurant.description),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    style: TextStyle(
                      //fontFamily: 'Nunito',
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                      color: Color(0xFF9D9FA4),
                      height: 1.3,
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 16),
                      SizedBox(width: 4),
                      Text(
                        "20-30 min",
                        style: TextStyle(
                          //fontFamily: 'Nunito',
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          height: 1.6,
                          color: Color(0xFF9D9FA4),
                        ),
                      ),
                      SizedBox(width: 10),
                      Icon(Icons.star, color: Colors.orange, size: 16),
                      SizedBox(width: 4),
                      Text(
                        restaurant.rate.toString(),
                        style: TextStyle(
                          //fontFamily: 'Nunito',
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
          ],
        ),
      ),
    );
  }
}
