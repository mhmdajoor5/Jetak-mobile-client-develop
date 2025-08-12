import 'package:flutter/material.dart';
import '../../elements/CuisinesCarouselWidget.dart';
import '../../models/cuisine.dart';

class HomeCuisinesSection extends StatelessWidget {
  final List<Cuisine> cuisines;

  const HomeCuisinesSection({
    Key? key,
    required this.cuisines,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CuisinesCarouselWidget(
      cuisines: cuisines,
    );
  }
} 