import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../helpers/helper.dart';
import '../models/food.dart';
import '../models/route_argument.dart';

class SuggestedProductCardWidget extends StatelessWidget {
  final Food food;
  final String heroTag;

  const SuggestedProductCardWidget({
    Key? key,
    required this.food,
    required this.heroTag,
  }) : super(key: key);

  String _minutesWord(BuildContext context) {
    final code = Localizations.localeOf(context).languageCode;
    if (code == 'ar') return 'دقيقة';
    if (code == 'he') return 'דקות';
    return 'min';
  }

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

  // اعرض السعر كما يعود من الـ API:
  // إذا كان هناك خصم، تم حفظ السعر الأصلي في discountPrice حسب منطق Food.fromJSON
  // وإلا فالسعر في الحقل price.
  double _apiPrice(Food f) {
    return (f.discountPrice > 0) ? f.discountPrice : f.price;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      margin: EdgeInsets.only(right: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.of(context).pushNamed(
            '/Food',
            arguments: RouteArgument(
              id: food.id,
              heroTag: heroTag,
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // صورة المنتج
            Stack(
              children: <Widget>[
                Hero(
                  tag: heroTag + food.id,
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                    child: CachedNetworkImage(
                      height: 140,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      imageUrl: _fixImageUrl(food.image?.thumb ?? ''),
                      placeholder: (context, url) => Container(
                        height: 140,
                        color: Colors.grey[200],
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[400]!),
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        height: 140,
                        color: Colors.grey[200],
                        child: Icon(
                          Icons.restaurant,
                          size: 40,
                          color: Colors.grey[400],
                        ),
                      ),
                    ),
                  ),
                ),
                // عرض الخصم إذا كان موجود
                if (food.discountPrice > 0)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'خصم',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            
            // معلومات المنتج
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // اسم المنتج
                  Text(
                    food.name,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: Color(0xFF2C3E50),
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: 6),
                  
                  // اسم المطعم
                  Text(
                    food.restaurant.name,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 13,
                      color: Color(0xFF7F8C8D),
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: 8),
                  
                  // الوصف
                  if (food.description.isNotEmpty)
                    Text(
                      food.description,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                        color: Color(0xFF95A5A6),
                        height: 1.3,
                      ),
                    ),
                  if (food.description.isNotEmpty) SizedBox(height: 8),
                  
                  // السعر والوزن
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // السعر من الـ API كما هو
                      Helper.getPrice(
                        _apiPrice(food),
                        context,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      
                      // الوزن
                      if (food.weight.isNotEmpty)
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Color(0xFFF8F9FA),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${food.weight}${food.unit.isNotEmpty ? ' ${food.unit}' : ''}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF6C757D),
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 12),
                  
                  // وقت التوصيل وزر الإضافة للسلة
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // وقت التوصيل
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 16,
                            color: Color(0xFF6C757D),
                          ),
                          SizedBox(width: 4),
                          Text(
                            '${food.estTime} ${_minutesWord(context)}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF6C757D),
                            ),
                          ),
                          SizedBox(width: 10),
                          Helper.getPrice(
                            _apiPrice(food),
                            context,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF6C757D),
                            ),
                          ),
                        ],
                      ),
                      
                      // زر الإضافة للسلة
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: Icon(
                            Icons.add_shopping_cart,
                            color: Colors.white,
                            size: 20,
                          ),
                          onPressed: () {
                            // إضافة المنتج للسلة
                            Navigator.of(context).pushNamed(
                              '/Food',
                              arguments: RouteArgument(
                                id: food.id,
                                heroTag: heroTag,
                              ),
                            );
                          },
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
