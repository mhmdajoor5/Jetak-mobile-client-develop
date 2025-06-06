import 'package:flutter/material.dart';
import '../../elements/CaregoriesCarouselWidget.dart';
import '../../models/category.dart';

class HomeCategoriesSection extends StatelessWidget {
  final List<Category> categories;

  const HomeCategoriesSection({
    Key? key,
    required this.categories,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CategoriesCarouselWidget(
      categories: categories,
    );
  }
}