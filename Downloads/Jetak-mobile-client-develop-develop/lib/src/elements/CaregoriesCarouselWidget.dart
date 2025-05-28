import 'package:flutter/material.dart';

import '../elements/CategoriesCarouselItemWidget.dart';
import '../elements/CircularLoadingWidget.dart';
import '../models/category.dart';

// ignore: must_be_immutable
class CategoriesCarouselWidget extends StatelessWidget {
  final List<Category> categories;

  CategoriesCarouselWidget({Key? key, required this.categories}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return categories.isEmpty
        ? CircularLoadingWidget(height: 150)
        : Container(
          height: 150,
          padding: EdgeInsets.symmetric(vertical: 10),
          child: ListView.builder(
            itemCount: categories.length,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              double _marginLeft = index == 0 ? 20 : 0;
              return CategoriesCarouselItemWidget(marginLeft: _marginLeft, category: categories[index]);
            },
          ),
        );
  }
}
