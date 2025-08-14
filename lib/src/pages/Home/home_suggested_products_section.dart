import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:restaurantcustomer/src/elements/CardWidget.dart';

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

  @override
  Widget build(BuildContext context) {
    if (widget.suggestedProducts.isEmpty) return SizedBox.shrink();

    return Container(
      margin: EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // العنوان
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '🟢 المنتجات المقترحة',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  'طلب مباشر',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          // وصف القسم
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'اطلب منتجك المفضل مباشرة بدون دخول متجر',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
          SizedBox(height: 15),
          // قائمة المنتجات
          Container(
            height: 300,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 15),
              itemCount: widget.suggestedProducts.length,
              itemBuilder: (context, index) {
                final food = widget.suggestedProducts[index];
                return CardWidget(
                  restaurant: food.restaurant,
                  heroTag: 'suggested_food_${food.id}',
                  food: food,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
