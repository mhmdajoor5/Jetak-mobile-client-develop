import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../generated/l10n.dart';
import '../helpers/helper.dart';
import '../models/restaurant.dart';

class GridCardWidget extends StatelessWidget {
  final Restaurant restaurant;

  const GridCardWidget({Key? key, required this.restaurant}) : super(key: key);

  String _fixImageUrl(String url) {
    if (url.contains('carrytechnologies.coimages')) {
      return url.replaceFirst('carrytechnologies.coimages', 'carrytechnologies.co/images');
    }
    // إذا كان الرابط يحتوي على صور غير موجودة، استخدم صورة افتراضية
    if (url.contains('restaurant.png') || url.contains('icons/avif.png')) {
      return 'https://carrytechnologies.co/storage/app/public/3856/SLIDES-01.png';
    }
    return url;
  }

  String _getDiscountText() {
    print("Entered _getDiscountText");

    if (restaurant.coupon != null && restaurant.coupon!.valid) {
      print("Found valid coupon: ${restaurant.coupon!.discountType}");
      return restaurant.coupon!.discountType == 'percent'
          ? '-${restaurant.coupon!.discount?.toStringAsFixed(0)}% off'
          : '-${restaurant.coupon!.discount?.toStringAsFixed(0)} ₪ off';
    } else if (restaurant.discountables.isNotEmpty &&
        restaurant.discountables[0].coupon != null &&
        restaurant.discountables[0].coupon!.valid) {
      final dCoupon = restaurant.discountables[0].coupon!;
      print("Found valid discountable coupon: ${dCoupon.discountType}");
      return dCoupon.discountType == 'percent'
          ? '-${dCoupon.discount?.toStringAsFixed(0)}% off'
          : '-${dCoupon.discount?.toStringAsFixed(0)} ₪ off';
    } else {
      print("No valid coupon");
      return '';
    }
  }


  bool _hasValidDiscount() {
    return (restaurant.coupon != null && restaurant.coupon!.valid) ||
        (restaurant.discountables.isNotEmpty &&
            restaurant.discountables[0].coupon != null &&
            restaurant.discountables[0].coupon!.valid);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
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
                    imageUrl: _fixImageUrl(restaurant.image.url),
                    placeholder: (context, url) => Image.asset(
                      'assets/img/loading.gif',
                      fit: BoxFit.cover,
                      height: 150,
                    ),
                    errorWidget: (context, url, error) {
                      print("Error loading restaurant image: $url - $error");
                      // محاولة إصلاح URL إذا كان مفقود فيه /
                      if (url.contains('carrytechnologies.coimages')) {
                        final fixedUrl = url.replaceFirst('carrytechnologies.coimages', 'carrytechnologies.co/images');
                        print("Attempting to fix restaurant image URL: $fixedUrl");
                      }
                      return Image.asset(
                        'assets/img/logo.png',
                        fit: BoxFit.cover,
                        height: 150,
                      );
                    },
                  ),
                ),
                if (_hasValidDiscount())
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicture.asset(
                            'assets/img/ticket-discount.svg',
                            height: 16,
                            width: 16,
                          ),
                          SizedBox(width: 5),
                          Text(
                            _getDiscountText(),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    restaurant.name,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(
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
                        S.of(context).twentyToThirtyMin,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          height: 1.6,
                          color: Color(0xFF9D9FA4),
                        ),
                      ),
                      SizedBox(width: 10),
                      Visibility(
                        visible: false,
                        child: Row(
                          children: [
                            Icon(Icons.star, color: Colors.orange, size: 16),
                            SizedBox(width: 4),
                            Text(
                              restaurant.rate.toString(),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                height: 1.6,
                                color: Color(0xFF9D9FA4),
                              ),
                            ),
                          ],
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
