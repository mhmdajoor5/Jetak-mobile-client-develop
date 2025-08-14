import 'package:flutter/material.dart';
import '../../elements/CuisinesCarouselWidget.dart';
import '../../models/cuisine.dart';

class HomeCuisinesSection extends StatelessWidget {
  final List<Cuisine> cuisines;
  final String? title;

  const HomeCuisinesSection({
    Key? key,
    required this.cuisines,
    this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Text(
              title!,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 18,
                color: Colors.black87,
              ),
            ),
          ),
        CuisinesCarouselWidget(
          cuisines: cuisines,
        ),
      ],
    );
  }
}