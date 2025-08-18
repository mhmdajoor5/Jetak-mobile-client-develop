import 'package:flutter/material.dart';

import '../elements/CuisinesCarouselItemWidget.dart';
import '../elements/CircularLoadingWidget.dart';
import '../models/cuisine.dart';

// ignore: must_be_immutable
class CuisinesCarouselWidget extends StatelessWidget {
  final List<Cuisine> cuisines;

  CuisinesCarouselWidget({Key? key, required this.cuisines}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('mElkerm Debug: CuisinesCarouselWidget build called with ${cuisines.length} cuisines');
    return cuisines.isEmpty
        ? CircularLoadingWidget(height: 150)
        : Container(
          height: 150,
          padding: EdgeInsets.symmetric(vertical: 10),
          child: ListView.builder(
            itemCount: cuisines.length,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              double _marginLeft = index == 0 ? 20 : 0;
              return CuisinesCarouselItemWidget(marginLeft: _marginLeft, cuisine: cuisines[index]);
            },
          ),
        );
  }
} 