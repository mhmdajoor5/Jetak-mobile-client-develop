import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:restaurantcustomer/generated/l10n.dart';
import 'package:restaurantcustomer/src/elements/CardWidget.dart';
import '../food.dart' show FoodWidget;
import '../../models/route_argument.dart';

import '../../models/food.dart';

class HomeSuggestedProductsSection extends StatefulWidget {
  final List<Food> suggestedProducts;

  const HomeSuggestedProductsSection({
    Key? key,
    required this.suggestedProducts,
  }) : super(key: key);

  @override
  _HomeSuggestedProductsSectionState createState() => _HomeSuggestedProductsSectionState();
}

class _HomeSuggestedProductsSectionState extends StateMVC<HomeSuggestedProductsSection> {
  String _tr(BuildContext context, {required String en, required String ar, required String he}) {
    final code = Localizations.localeOf(context).languageCode;
    if (code == 'ar') return ar;
    if (code == 'he') return he;
    return en;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.suggestedProducts.isEmpty) return SizedBox.shrink();

    return Container(
      margin: EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // العنوان
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    _tr(context,
                        en: 'Suggested products',
                        ar: 'المنتجات المقترحة',
                        he: 'מוצרים מומלצים'),
                    textAlign: TextAlign.left,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      height: 1.6,
                      letterSpacing: 0,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Text(
                  _tr(context,
                      en: 'Direct order',
                      ar: 'طلب مباشر',
                      he: 'הזמנה ישירה'),
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12),
          // وصف القسم
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              _tr(context,
                  en: 'Order your favorite product directly without entering a store',
                  ar: 'اطلب منتجك المفضل مباشرة بدون دخول متجر',
                  he: 'הזמן את המוצר המועדף ישירות בלי להיכנס לחנות'),
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
          SizedBox(height: 12),
          // قائمة المنتجات
          Container(
            height: 281,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16),
              itemCount: widget.suggestedProducts.length,
              itemBuilder: (context, index) {
                final food = widget.suggestedProducts[index];
                return GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) {
                        return FractionallySizedBox(
                          heightFactor: 0.9,
                          child: Material(
                            color: Colors.white,
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
                            child: Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: FoodWidget(
                                routeArgument: RouteArgument(id: food.id, param: food),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                  child: CardWidget(
                    restaurant: food.restaurant,
                    heroTag: 'suggested_food_${food.id}',
                    food: food,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
