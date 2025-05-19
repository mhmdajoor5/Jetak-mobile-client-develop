import 'package:flutter/material.dart';

import '../elements/FoodsCarouselItemWidget.dart';
import '../elements/FoodsCarouselLoaderWidget.dart';
import '../models/food.dart';

class FoodsCarouselWidget extends StatelessWidget {
  final List<Food> foodsList;
  final String heroTag;

  FoodsCarouselWidget({Key? key, required this.foodsList, required this.heroTag}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return foodsList.isEmpty
        ? const FoodsCarouselLoaderWidget()
        : Container(
          height: 210,
          color: Theme.of(context).primaryColor,
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: ListView.builder(
            itemCount: foodsList.length,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              double _marginLeft = index == 0 ? 20 : 0;
              return FoodsCarouselItemWidget(heroTag: heroTag, marginLeft: _marginLeft, food: foodsList[index]);
            },
          ),
        );
  }
}
